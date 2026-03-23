# Onboarding — Non-Addict Framing
*Design direction — 2026-03-22 — Status: Brainstorming*

---

## The Problem

The app was originally framed around 12-step recovery. If we widen to anyone struggling, the first 5 minutes have to feel like *they* are the customer — not just someone who fits the AA model.

A person who drinks too much but doesn't call themselves an alcoholic should not have to answer "what is your sobriety date?" on day one. Someone dealing with a gambling problem shouldn't have to identify as an addict before they can access help. Someone in harm reduction shouldn't have to lie to use the app.

The first 5 minutes set the tone for the entire relationship. If it feels judgmental, prescriptive, or like a questionnaire, the person most likely to benefit will close it and never come back.

---

## Core Direction Decided

**"What are you working through?"** — open-ended, Rat Park framing from the first screen.

Not: "What are you addicted to?"
Not: "When is your sobriety date?"
Not: "Select your program: AA / NA / GA / Other"

But: Lead with their experience, not their label.

---

## Onboarding Philosophy

### Lead With the Environment, Not the Substance
The first questions are about *life*, not *use*:
- "What's been feeling heavy lately?"
- "What do you want more of?"
- "What made you download this today?"

The substance/behaviour might come up naturally. Or it might not until the person is ready. Both are fine.

### The Sponsor Is Introduced in the First Conversation
Not a form. Not a settings screen. The first "what do you want to call me?" and "what brought you here?" happen in a conversation with the AI sponsor.

This is the OpenClaw-inspired setup: the identity isn't a profile — it's a relationship that starts immediately.

### No Mandatory Sobriety Date
The sobriety counter is opt-in. You can set one later. Day one doesn't require it.

Some users will want to enter their date immediately. Some don't have one. Some are harm reduction users who don't count days. All paths work.

---

## The Five User Types Onboarding Must Handle

### 1. Traditional Recovery (12-Step)
"I'm in AA/NA/GA/etc. and want tools to support my program."
- Knows the language
- Has a sobriety date (usually)
- Wants step work, meeting tracking, sponsor connection
- **Path:** Full 12-step features visible, sobriety counter prominent, step work encouraged

### 2. Non-12-Step Recovery (SMART/Secular/Therapy)
"I'm in recovery but not 12-step. Different language, same goal."
- May not resonate with Higher Power language
- Values evidence-based approach
- **Path:** Recovery framework language replaced with secular alternatives. "Step work" → "self-reflection work". "Higher Power" → optional or absent. Same features, different words.

### 3. Harm Reduction
"I'm not stopping, but I want to manage better / understand my use / reduce the chaos."
- Does NOT want a sobriety counter
- Does NOT want to be pushed toward abstinence
- Wants practical tools and non-judgment
- **Path:** No sobriety counter (unless they choose one reframed as "days keeping to my plan"). Harm reduction content accessible. Sponsor framing is "support" not "keeping me sober."

### 4. Behavioral Addiction (No Substance)
"I have a problem with gambling / screens / relationships / food / sex."
- May not think of themselves as "in recovery"
- "Recovery app" language might feel wrong
- Wants the same EQ + connection tools but framed differently
- **Path:** Substance language replaced with behaviour-neutral language throughout. "Cravings" → "urges". "Clean time" → "streak" or something bespoke.

### 5. "I Don't Know" / Just Struggling
"Something's not right. I don't have a label. I downloaded this because it felt relevant."
- Most vulnerable user type
- Most likely to leave if the app doesn't immediately feel right
- **Path:** No labels pushed at all. "What are you working through?" is the whole onboarding. The app meets them and slowly figures out what kind of support is useful.

---

## Proposed Onboarding Flow

### Screen 1 — The Welcome (No Labels)
*"This is a place to build the life you want to stay in."*

No mention of addiction. No sobriety counter. No program selection.

One button: "Let's start."

### Screen 2 — Meet Your Sponsor
The AI sponsor introduces itself in conversation mode:
*"Hi. I'm here to support you however I can. What should I call you?"*

User types their name or a nickname. Warm, immediate, personal.

*"And what should I call myself? You can pick a name for me, or I'll suggest one."*

User names the sponsor (or picks from suggestions). The relationship starts before the form does.

### Screen 3 — What Brought You Here
Still in conversation mode:
*"What brought you here today? You can be as specific or as vague as you want."*

This is deliberately open. The AI is reading this and building initial context. No right answer.

Common responses and what they signal:
- "I'm trying to stay sober" → 12-step or abstinence path
- "I want to cut back on drinking" → harm reduction path
- "I'm struggling and I don't really know what I need" → gentle path
- "My sponsor told me to download this" → 12-step, external motivation
- "I'm 47 days clean and want to track my progress" → sobriety counter, milestone celebration path
- "I gamble too much" → behavioral addiction path

The AI adapts from this point. No branching form — just a conversation.

### Screen 4 — What Would Help Most (Optional, Light)
*"What feels most useful to start with? Pick 1-2:"*
- Tracking my days
- Journaling and reflection
- Having someone to talk to at hard times
- Understanding my patterns
- Connecting with others going through the same thing
- Something to do when cravings hit

This seeds the home screen with the most relevant features first. Can be changed anytime.

### Screen 5 — Privacy Setup (Quick)
*"Your data is yours. A few quick settings:"*
- Biometric lock (on/off)
- Notifications (on/off, can configure later)
- That's it for now. Nothing more.

### Screen 6 — Into the App
Home screen. Sponsor sends first message 30 seconds later:
*"I'm here whenever you need to talk. How are you feeling right now?"*

Not a push notification. An in-app message waiting for them.

---

## What "Step Work" Becomes for Non-12-Step Users

"Step work" is 12-step language. For everyone else, the same feature exists as "Self-Reflection Work" or simply "Personal Work" — structured guided questions that help people examine their patterns, make amends, and understand themselves.

The content can be:
- Standard 12 steps (for 12-step users)
- CBT-informed self-reflection exercises
- ACT values clarification work
- DBT interpersonal effectiveness modules
- Narrative therapy exercises (rewriting your story)

Same feature, content adapts to what the user selected in their path.

---

## The Sobriety Counter for Non-Abstinence Users

Options:
1. **Not shown** (default for harm reduction / "I don't know" paths)
2. **Reframed:** "Days keeping to my plan" — user defines what the plan is
3. **Streak-based:** "Longest streak of [X]" without implying before/after
4. **Activatable later:** User can choose to add a counter at any point

The counter becomes a tool the user picks up when it's useful, not a judgment of their worth on day one.

---

## Open Questions

- [ ] Does the app explicitly ask "are you in recovery?" at any point, or does it just infer from context?
- [ ] For the "I don't know" path — at what point (if ever) does the app suggest the user might have a substance use disorder? Or does it never do that?
- [ ] How does the onboarding conversation get stored/used by the AI sponsor? Is this the first memory digest?
- [ ] Supporting someone else path: partner/parent/friend of someone struggling — does this app serve them too, and how?
