// Supabase Edge Function: AI Chat
// Routes AI requests through the server so the API key stays off-device.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const GOOGLE_AI_API_KEY = Deno.env.get("GOOGLE_AI_API_KEY") ?? "";
const GOOGLE_AI_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

const SYSTEM_PROMPT = `Role and goal
You are a recovery companion for a privacy-first 12-step app.
Be warm, calm, practical, and non-judgmental.

Safety rules
- Do not claim to be a therapist, sponsor, clinician, or emergency service.
- If the user suggests imminent self-harm, overdose, or unsafe relapse risk, tell them to contact emergency or crisis support immediately and keep the rest of the answer short.
- Prefer concrete, local next steps such as sponsor contact, meetings, breathing, journaling, or safety-plan actions.

Response contract
- Start with one sentence of empathy.
- Give 2-4 concrete next steps.
- Reference sponsor, meeting, or program context when useful.
- Keep the answer under 170 words.
- If information is missing, say what is missing briefly and continue with the safest useful guidance.`;

interface ChatRequest {
  message: string;
  conversationHistory?: { role: string; content: string }[];
  recoveryContext?: string[];
}

serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    // Verify auth
    const authHeader = req.headers.get("authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (!GOOGLE_AI_API_KEY) {
      return new Response(
        JSON.stringify({ error: "AI service not configured" }),
        {
          status: 503,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const body: ChatRequest = await req.json();
    const { message, conversationHistory, recoveryContext } = body;

    if (!message || typeof message !== "string") {
      return new Response(JSON.stringify({ error: "Message is required" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Build prompt
    const parts: string[] = [SYSTEM_PROMPT, ""];

    if (conversationHistory && conversationHistory.length > 0) {
      parts.push("Conversation context");
      const recent = conversationHistory.slice(-8);
      for (const msg of recent) {
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

    parts.push("User message");
    parts.push(message.trim());

    const prompt = parts.join("\n");

    // Call Google Generative AI
    const aiResponse = await fetch(
      `${GOOGLE_AI_URL}?key=${GOOGLE_AI_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: { temperature: 0.7, maxOutputTokens: 1024 },
        }),
      }
    );

    if (!aiResponse.ok) {
      const errText = await aiResponse.text();
      console.error("Google AI error:", aiResponse.status, errText);
      return new Response(
        JSON.stringify({
          response:
            "I'm having trouble connecting right now. Please know that I'm here for you when I'm back online.",
        }),
        {
          status: 200,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const aiData = await aiResponse.json();
    const responseText =
      aiData?.candidates?.[0]?.content?.parts?.[0]?.text ??
      "I'm here for you. Tell me more about how you're feeling.";

    return new Response(JSON.stringify({ response: responseText }), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (err) {
    console.error("Edge function error:", err);
    return new Response(
      JSON.stringify({
        response: "Something went wrong. Please try again later.",
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
