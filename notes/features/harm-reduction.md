# Harm Reduction — First-Class Citizen
*Philosophy + Feature implications — 2026-03-22*

---

## What Harm Reduction Is

Harm reduction is a public health philosophy and set of interventions that aim to reduce the negative consequences of drug use without requiring abstinence. It meets people where they are.

Examples:
- Needle exchanges (reduce HIV/Hep C transmission)
- Naloxone distribution (reverse opioid overdose)
- Drug checking services (fentanyl test strips)
- Supervised consumption sites
- Managed alcohol programs
- Motivational interviewing (supporting any positive change, not just stopping)

**The underlying principle:** People who use drugs are human beings whose lives have value. Keeping them alive and healthier — even if they're still using — is a success.

---

## Why This App Must Be Harm Reduction Compatible

1. **Many people aren't ready to stop.** The decision to pursue abstinence is a process, not a switch. An app that only serves people who've already decided to stop excludes the people who need help most.

2. **Forced abstinence framing causes harm.** When people fail (they will relapse — it's statistically normal), shame framing makes them disappear. "I failed the program" leads to worse outcomes than "I had a setback and I'm continuing."

3. **H's own philosophy.** H maintained a managed relationship with meth use while working, studying, and maintaining a private life for years before choosing to stop. The behaviour wasn't the problem — the underlying condition (narcolepsy) was. The self-medication had logic.

4. **Rat Park is inherently harm reduction.** If the goal is building a richer environment, that applies equally to people who aren't stopping and people who are. More connection, more meaning, more skills — all reduce harm regardless of abstinence status.

---

## How Harm Reduction Appears in the App

### Onboarding
No forced binary: "I want to get sober" vs "I'm already sober."

Options include:
- "I want to stop completely"
- "I want to use less or manage it better"
- "I want to understand my relationship with [substance/behaviour] better"
- "I'm not sure yet"
- "I'm supporting someone else"

All paths lead to the same Rat Park building. Different emphasis, different metrics, same philosophy.

### The Sobriety Counter (Reframed)
For abstinence-focused users: days clean, milestone celebrations, the full achievement system.

For harm reduction users: optional, reframeable.
- "Days since my last [specific behaviour]"
- "Weeks since I used more than my limit"
- "Days I've kept to my plan"
- Or: no counter at all. Track something else entirely (days of journaling, days of check-ins, connections made).

The counter is a tool, not a requirement. Some people find it motivating. Some find it a countdown to the next relapse. The app accommodates both.

### The AI Sponsor in Harm Reduction Mode
The sponsor never:
- Tells a harm reduction user they should be aiming for abstinence
- Frames a slip as failure if abstinence wasn't the goal
- Uses 12-step language with someone who hasn't opted into that framework

The sponsor does:
- Ask about the user's own goals and holds them accountable to *those goals*
- Notice when use is increasing without judgment
- Proactively name risk when it's genuine: *"You've mentioned using every day this week. That's a pattern worth looking at — not because I'm judging it, but because it's different from what you told me you wanted."*
- Always make space for the conversation to shift: *"Has your thinking about what you want changed at all?"*

### Check-In Flow
Daily check-ins work for harm reduction users too — slightly reframed:
- Mood (same)
- Craving/urge level (same)
- "Did you use today?" → optional, reframed as "How did today go with [substance/behaviour]?" — not a gotcha, a reflection prompt
- "One good thing" (same)

The data still feeds the sponsor's context and the progress dashboard. The framing shifts from compliance to curiosity.

### The Community Platform
Harm reduction has its own space in the community (see `community-platform.md`). No abstinence requirement for any tier. The Harm Reduction space is explicitly non-judgmental and practically focused.

Users in the Harm Reduction space should never encounter:
- "You need to just stop"
- "You're not really in recovery"
- "You're enabling yourself"

The moderation system catches this. Posts that shame harm reduction are flagged and removed.

---

## The Language Guide (Internal)

Language matters enormously in recovery spaces. These are principles for how the app communicates.

**Use:**
- Person-first language: "person who uses drugs" not "addict" (unless they self-identify)
- "Substance use" or "use" rather than "abuse"
- "Slip" or "setback" rather than "failure" or "relapse" (though relapse is clinically accurate, failure framing is harmful)
- "Person in recovery" (not "recovering addict" — recovery is an identity, not a modifier)
- "Use disorder" if clinical framing is needed

**Avoid:**
- "Clean" as the opposite of using (implies people who use are "dirty")
- "Dirty urine" / "dirty test"
- "Junkie", "drunk", "crackhead" (even self-referentially — the app doesn't reinforce this)
- "Falling off the wagon" (the wagon is a bad metaphor — implies a single track, binary states)
- "Hitting rock bottom" (implies people can only change from the worst possible point — demonstrably false, and dangerous if it means waiting)

---

## The Slip/Relapse Protocol

When a user reports or the sponsor detects a slip:

**First response (always):** No shame. "Tell me what happened."

Not: "Why did you do that?" (implies failure)
Not: "How many days did you have?" (makes the counter the metric of worth)
But: "What was going on? What was the last hour like before it happened?"

**Then:** Understand the trigger. What need was being met? What was the Rat Park condition that was missing?

**Then:** What's the next right thing? Not "start over." Not "you lost your streak." But: what's the next 10 minutes? Who's one person you could talk to?

**The sponsor never:**
- Withdraws warmth after a slip
- Makes the user feel they've disappointed it
- Treats the slip as evidence the user is hopeless

**The sponsor always:**
- Welcomes the user back without judgment whenever they return
- Treats the slip as data, not verdict
- Focuses on what comes next

---

## Open Questions

- [ ] At what point (if any) does the sponsor express genuine concern about harm reduction escalating to dangerous territory? What's the threshold?
- [ ] Does the app offer specific harm reduction resources (naloxone locators, fentanyl test strip info, safe use guides)? These are genuinely life-saving.
- [ ] How does the slip/relapse protocol work with the existing crisis features? Is there a dedicated "I slipped" flow?
