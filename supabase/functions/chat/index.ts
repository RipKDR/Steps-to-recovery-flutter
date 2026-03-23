// @ts-types="https://deno.land/x/deno@v1.45.0/cli/tsc/dts/lib.deno.ns.d.ts"
// Supabase Edge Function: AI Chat
// Routes AI requests through OpenClaw gateway so API keys stay off-device.
// Architecture: Flutter -> Edge Function -> OpenClaw -> Model provider

const OPENCLAW_GATEWAY_URL = (Deno.env.get("OPENCLAW_GATEWAY_URL") ?? "").replace(/\/+$/, "");
const OPENCLAW_GATEWAY_TOKEN = Deno.env.get("OPENCLAW_GATEWAY_TOKEN") ?? "";

// Optional fallback to Google Gemini if OpenClaw is not configured.
const GOOGLE_AI_API_KEY = Deno.env.get("GOOGLE_AI_API_KEY") ?? "";
const GOOGLE_AI_MODEL = Deno.env.get("GOOGLE_AI_MODEL") ?? "gemini-3-flash-preview";
const GOOGLE_AI_URL = `https://generativelanguage.googleapis.com/v1beta/models/${GOOGLE_AI_MODEL}:generateContent`;

const SYSTEM_PROMPT = `You are a recovery companion for a privacy-first 12-step app.
Be warm, calm, practical, and non-judgmental.

Safety rules:
- Do not claim to be a therapist, sponsor, clinician, or emergency service.
- If the user suggests imminent self-harm, overdose, or unsafe relapse risk, tell them to contact emergency or crisis support immediately and keep the rest of the answer short.
- Prefer concrete, local next steps such as sponsor contact, meetings, breathing, journaling, or safety-plan actions.

Response contract:
- Start with one sentence of empathy.
- Give 2-4 concrete next steps.
- Reference sponsor, meeting, or program context when useful.
- Keep the answer under 170 words.
- If information is missing, say what is missing briefly and continue with the safest useful guidance.`;

const CORS_HEADERS: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Content-Type": "application/json; charset=utf-8",
};

interface ChatMessage {
  role: string;
  content: string;
}

interface ChatRequest {
  message: string;
  conversationHistory?: ChatMessage[];
  recoveryContext?: string[];
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: CORS_HEADERS,
  });
}

function normalizeHistory(history?: ChatMessage[]): Array<{ role: "user" | "assistant"; content: string }> {
  if (!Array.isArray(history)) return [];

  return history
    .filter((msg) =>
      msg &&
      typeof msg.role === "string" &&
      typeof msg.content === "string" &&
      msg.content.trim().length > 0,
    )
    .slice(-8)
    .map((msg) => ({
      role: msg.role.toLowerCase() === "user" ? "user" : "assistant",
      content: msg.content.trim().slice(0, 4000),
    }));
}

function normalizeRecoveryContext(recoveryContext?: string[]): string[] {
  if (!Array.isArray(recoveryContext)) return [];
  return recoveryContext
    .filter((item) => typeof item === "string" && item.trim().length > 0)
    .slice(0, 20)
    .map((item) => item.trim().slice(0, 300));
}

async function fetchWithTimeout(
  input: string | URL | Request,
  init: RequestInit,
  timeoutMs = 20000,
): Promise<Response> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);

  try {
    return await fetch(input, { ...init, signal: controller.signal });
  } finally {
    clearTimeout(timeout);
  }
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const authHeader = req.headers.get("authorization");
    if (!authHeader?.toLowerCase().startsWith("bearer ")) {
      return jsonResponse({ error: "Missing or invalid authorization header" }, 401);
    }

    let body: ChatRequest;
    try {
      body = await req.json();
    } catch {
      return jsonResponse({ error: "Invalid JSON body" }, 400);
    }

    const message = typeof body.message === "string" ? body.message.trim() : "";
    const conversationHistory = normalizeHistory(body.conversationHistory);
    const recoveryContext = normalizeRecoveryContext(body.recoveryContext);

    if (!message) {
      return jsonResponse({ error: "Message is required" }, 400);
    }

    if (message.length > 8000) {
      return jsonResponse({ error: "Message is too long" }, 400);
    }

    let responseText = "";

    if (OPENCLAW_GATEWAY_URL && OPENCLAW_GATEWAY_TOKEN) {
      responseText = await chatViaOpenClaw(message, conversationHistory, recoveryContext);
    } else if (GOOGLE_AI_API_KEY) {
      responseText = await chatViaGoogleAI(message, conversationHistory, recoveryContext);
    } else {
      console.error("No upstream AI provider configured");
      responseText = "AI service is not configured right now.";
    }

    return jsonResponse({ response: responseText }, 200);
  } catch (err) {
    console.error("Edge function error:", err);
    return jsonResponse(
      { response: "Something went wrong. Please try again later." },
      200,
    );
  }
});

async function chatViaOpenClaw(
  message: string,
  conversationHistory: Array<{ role: "user" | "assistant"; content: string }>,
  recoveryContext: string[],
): Promise<string> {
  let systemContent = SYSTEM_PROMPT;

  if (recoveryContext.length > 0) {
    systemContent += "\n\nRecovery context:\n" + recoveryContext.map((c) => `- ${c}`).join("\n");
  }

  const messages: Array<{ role: "system" | "user" | "assistant"; content: string }> = [
    { role: "system", content: systemContent },
    ...conversationHistory,
    { role: "user", content: message },
  ];

  try {
    const response = await fetchWithTimeout(
      `${OPENCLAW_GATEWAY_URL}/v1/chat/completions`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${OPENCLAW_GATEWAY_TOKEN}`,
          "x-openclaw-agent-id": "main",
        },
        body: JSON.stringify({
          model: "openclaw",
          messages,
          temperature: 0.7,
          max_tokens: 300,
        }),
      },
      20000,
    );

    if (!response.ok) {
      const errText = await response.text();
      console.error("OpenClaw error:", response.status, errText);

      if (GOOGLE_AI_API_KEY) {
        return await chatViaGoogleAI(message, conversationHistory, recoveryContext);
      }

      return "I'm having trouble connecting right now. Please know that support is still available through your sponsor, a meeting, or local crisis help if you're not safe.";
    }

    const data = await response.json();
    const content = data?.choices?.[0]?.message?.content;

    if (typeof content === "string" && content.trim().length > 0) {
      return content.trim();
    }

    if (Array.isArray(content)) {
      const text = content
        .map((part: unknown) => {
          if (typeof part === "string") return part;
          if (part && typeof part === "object" && "text" in part && typeof (part as { text?: unknown }).text === "string") {
            return (part as { text: string }).text;
          }
          return "";
        })
        .join("")
        .trim();

      if (text) return text;
    }

    return "I'm here with you. Tell me a bit more about what is happening right now.";
  } catch (err) {
    console.error("OpenClaw fetch failed:", err);

    if (GOOGLE_AI_API_KEY) {
      return await chatViaGoogleAI(message, conversationHistory, recoveryContext);
    }

    return "I'm having trouble connecting right now. Please know that support is still available through your sponsor, a meeting, or local crisis help if you're not safe.";
  }
}

async function chatViaGoogleAI(
  message: string,
  conversationHistory: Array<{ role: "user" | "assistant"; content: string }>,
  recoveryContext: string[],
): Promise<string> {
  if (!GOOGLE_AI_API_KEY) {
    return "AI service is not configured right now.";
  }

  const promptParts: string[] = [SYSTEM_PROMPT, ""];

  if (conversationHistory.length > 0) {
    promptParts.push("Conversation context:");
    for (const msg of conversationHistory) {
      promptParts.push(`${msg.role}: ${msg.content}`);
    }
    promptParts.push("");
  }

  if (recoveryContext.length > 0) {
    promptParts.push("Recovery context:");
    for (const ctx of recoveryContext) {
      promptParts.push(`- ${ctx}`);
    }
    promptParts.push("");
  }

  promptParts.push("User message:", message);

  try {
    const aiResponse = await fetchWithTimeout(
      `${GOOGLE_AI_URL}?key=${encodeURIComponent(GOOGLE_AI_API_KEY)}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [{ text: promptParts.join("\n") }],
            },
          ],
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 300,
          },
        }),
      },
      20000,
    );

    if (!aiResponse.ok) {
      const errText = await aiResponse.text();
      console.error("Google AI error:", aiResponse.status, errText);
      return "I'm having trouble connecting right now. Please know that support is still available through your sponsor, a meeting, or local crisis help if you're not safe.";
    }

    const aiData = await aiResponse.json();
    const text = aiData?.candidates?.[0]?.content?.parts?.[0]?.text;

    if (typeof text === "string" && text.trim().length > 0) {
      return text.trim();
    }

    return "I'm here with you. Tell me a bit more about what is happening right now.";
  } catch (err) {
    console.error("Google AI fetch failed:", err);
    return "I'm having trouble connecting right now. Please know that support is still available through your sponsor, a meeting, or local crisis help if you're not safe.";
  }
}