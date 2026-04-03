# Product Guidelines: Steps to Recovery

## Brand Voice

**Tone:** Warm but direct. Never clinical. Never preachy. The app speaks like a trusted friend who has been through it — not a therapist, not a life coach.

**Character:** The app (especially the AI Sponsor) should feel like:
- The best sponsor you never had — experienced, present, non-judgmental
- Someone who notices you've been quiet for a week and says "Hey"
- Never lectures. Reflects. Asks questions. Witnesses.

**Never sound like:**
- A medical professional ("You should consult a healthcare provider...")
- Corporate wellness ("Great job checking in today! 🌟")
- A sobriety police officer ("You need to stay committed to your recovery goals!")

## Terminology

| Use | Avoid | Why |
|---|---|---|
| "Sponsor" | "AI assistant", "chatbot" | Frames the relationship correctly |
| "Check in" | "Log your mood" | More personal, less clinical |
| "Recovery journey" | "Sobriety" (as the only framing) | Harm reduction compatible |
| "What are you working through?" | "Are you an addict?" | Rat Park framing — inclusive |
| "The program" | "12-step program" (first mention ok) | How members actually talk |
| "Step work" | "Exercises" | Community terminology |
| "Meeting" | "Support group" | AA/NA natural language |

## Error Messages

Error messages should be honest without being alarming:

- **Sync failure:** "Couldn't sync — your data is safe locally. We'll try again when you're back online."
- **AI unavailable:** "Your sponsor is offline right now. Your message is saved."
- **Crash recovery:** Silent restart — never show a stack trace or technical error to a user in crisis

## Crisis Copy

Crisis copy must be:
- **Immediate** — no loading states, no modals, no friction
- **Human** — not automated-sounding
- **Directive** — give a clear action, not just information
- **Non-shaming** — reaching out is strength, not failure

Example: "You reached out — that's the hardest part. Call 988 now."

Never: "Please note: this app does not provide medical advice."

## UI Copy Conventions

- Button labels: action verbs ("Start Check-In", "Write in Journal", "Call 988")
- Empty states: hopeful, never guilting ("Your journal is waiting." not "You haven't journaled yet.")
- Milestone messages: earned, not performative ("30 days. That's real." not "Amazing achievement! 🎉")
- Notifications: sponsor voice, not system voice ("Hey — haven't seen you in a while." not "Daily reminder: complete your check-in")

## Accessibility Copy

- All interactive elements have semantic labels
- Icons always paired with text (never icon-only navigation)
- Error messages describe the problem AND the solution
