// Supabase Edge Function: AI Chat
// Routes AI requests through OpenClaw gateway so API keys stay off-device.
// Architecture: Flutter → Edge Function → OpenClaw → Kimi (or any model)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const OPENCLAW_GATEWAY_URL = Deno.env.get("OPENCLAW_GATEWAY_URL") ?? "";
const OPENCLAW_GATEWAY_TOKEN = Deno.env.get("OPENCLAW_GATEWAY_TOKEN") ?? "";

// Fallback to Google AI if OpenClaw is not configured (backwards compat)
const GOOGLE_AI_API_KEY = Deno.env.get("GOOGLE_AI_API_KEY") ?? "";
const GOOGLE_AI_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

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

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface ChatRequest {
  message: string;
  conversationHistory?: { role: string; content: string }[];
  recoveryContext?: string[];
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }

  try {
    const authHeader = req.headers.get("authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const body: ChatRequest = await req.json();
    const { message, conversationHistory, recoveryContext } = body;

    if (!message || typeof message !== "string") {
      return new Response(JSON.stringify({ error: "Message is required" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const responseText = OPENCLAW_GATEWAY_URL && OPENCLAW_GATEWAY_TOKEN
      ? await chatViaOpenClaw(message, conversationHistory, recoveryContext)
      : await chatViaGoogleAI(message, conversationHistory, recoveryContext);

    return new Response(JSON.stringify({ response: responseText }), {
      status: 200,
      headers: { "Content-Type": "application/json", ...CORS_HEADERS },
    });
  } catch (err) {
    console.error("Edge function error:", err);
    return new Response(
      JSON.stringify({ response: "Something went wrong. Please try again later." }),
      { status: 200, headers: { "Content-Type": "application/json", ...CORS_HEADERS } }
    );
  }
});

async function chatViaOpenClaw(
  message: string,
  conversationHistory?: { role: string; content: string }[],
  recoveryContext?: string[]
): Promise<string> {
  // Build system prompt, optionally appending recovery context
  let systemContent = SYSTEM_PROMPT;
  if (recoveryContext && recoveryContext.length > 0) {
    systemContent += "\n\nRecovery context:\n" +
      recoveryContext.map((c) => `- ${c}`).join("\n");
  }

  // Build OpenAI-format messages array
  const messages: { role: string; content: string }[] = [
    { role: "system", content: systemContent },
  ];

  // Include last 8 turns of conversation history
  if (conversationHistory && conversationHistory.length > 0) {
    const recent = conversationHistory.slice(-8);
    for (const msg of recent) {
      messages.push({
        role: msg.role.toLowerCase() === "user" ? "user" : "assistant",
        content: msg.content,
      });
    }
  }

  messages.push({ role: "user", content: message.trim() });

  const response = await fetch(
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
        max_tokens: 1024,
      }),
    }
  );

  if (!response.ok) {
    const errText = await response.text();
    console.error("OpenClaw error:", response.status, errText);
    return "I'm having trouble connecting right now. Please know that I'm here for you when I'm back online.";
  }

  const data = await response.json();
  return data?.choices?.[0]?.message?.content ??
    "I'm here for you. Tell me more about how you're feeling.";
}

async function chatViaGoogleAI(
  message: string,
  conversationHistory?: { role: string; content: string }[],
  recoveryContext?: string[]
): Promise<string> {
  if (!GOOGLE_AI_API_KEY) {
    return "AI service not configured.";
  }

  const parts: string[] = [SYSTEM_PROMPT, ""];

  if (conversationHistory && conversationHistory.length > 0) {
    parts.push("Conversation context");
    for (const msg of conversationHistory.slice(-8)) {
      parts.push(`${msg.role}: ${msg.content}`);
    }
    parts.push("");
  }

  if (recoveryContext && recoveryContext.length > 0) {
    parts.push("Recovery context");
    for (const ctx of recoveryContext) {
      parts.push(`- ${ctx}`);
    }
    parts.push("");
  }

  parts.push("User message", message.trim());

  const aiResponse = await fetch(`${GOOGLE_AI_URL}?key=${GOOGLE_AI_API_KEY}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ parts: [{ text: parts.join("\n") }] }],
      generationConfig: { temperature: 0.7, maxOutputTokens: 1024 },
    }),
  });

  if (!aiResponse.ok) {
    console.error("Google AI error:", aiResponse.status);
    return "I'm having trouble connecting right now. Please know that I'm here for you when I'm back online.";
  }

  const aiData = await aiResponse.json();
  return aiData?.candidates?.[0]?.content?.parts?.[0]?.text ??
    "I'm here for you. Tell me more about how you're feeling.";
}
