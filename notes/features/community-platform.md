# Community Platform — The Rat Park Social Layer
*Feature design — 2026-03-22 — Status: Brainstorming, not yet specced*

---

## What It Is

The actual Rat Park being built. Not Reddit-for-recovery. Not a support group forum. A genuine knowledge-sharing and connection layer for people who are building their lives.

The AI sponsor is the bridge when human connection isn't available. This is the human side. The community is the Rat Park itself — the enriched environment where people want to stay.

**Primary concern:** Do not let it become a place to source drugs.
**Secondary concern:** Do not let it become a place where vulnerable people are preyed upon.
**Third concern:** Do not let it become a toxic shame spiral where people pile on failures.

---

## Three Earned Tiers of Access

### Tier 1 — Observer (everyone starts here, immediately)
**Can:** Browse feed, like posts, save to "For Me" folder, read all content
**Cannot:** Post, comment, DM anyone

**Why this works for day-one users:** They get immediate value — reading others' experiences, finding resonant posts, building their personal library. They're learning the culture of the community before they're allowed to shape it. The act of saving to "For Me" is itself valuable — it's curation, it's saying "this matters to me."

### Tier 2 — Contributor (earned)
**Unlocks:** Creating posts, commenting on others' posts
**Criteria:**
- Complete onboarding (takes ~10 min)
- 7 days of genuine app engagement (check-ins, journaling, sponsor chat — not just opens)
- At least one completed step/reflection exercise

**The logic:** 7 days of real investment. Someone who just wants to source drugs is not going to check in daily, journal, and do step work for a week first. The barrier is meaningful without being punitive.

### Tier 3 — Connected (earned further)
**Unlocks:** Direct 1-on-1 messaging with other Tier 3 users
**Criteria:**
- 30 days of sustained engagement
- At least one human contact established in the Contact Hub (sponsor, accountability partner, or trusted person)

**The logic:** You have to have human connection in your own life before you get to reach into someone else's. This also means anyone receiving a DM knows the sender has done 30 days of real work.

---

## The "For Me" Folder

Personal recovery resource library. Posts that resonated, strategies someone else tried that might work, things that hit home.

**This isn't just bookmarks.** It becomes a living personal reference:
- Posts about managing Sunday evenings
- Someone's take on making amends
- A description of what early recovery actually felt like that matches your own
- A coping strategy you want to try

**AI Integration:** The sponsor actively references the folder.
*"You saved three posts about loneliness last week. What's going on?"*
*"You bookmarked that post about calling your sponsor at 2am — have you tried that?"*

The folder passively feeds the sponsor's understanding of the user without the user having to explain anything. It's a window into what they're finding meaningful at any given moment.

---

## Content Formats (Structured, Not Freeform)

Rather than an open text box, posts follow loose formats that encourage useful contribution and make moderation easier.

**Suggested formats:**
- **What worked for me** — *"When cravings hit on weekends I started [X]. It's been 3 weeks."* Practical, actionable.
- **Struggling right now** — *"Having a hard day. Not looking for advice, just to say it out loud."* Validation-seeking, not advice-seeking.
- **Milestone** — *"90 days today."* Celebration. Community can react and comment.
- **Question** — *"Has anyone dealt with [X]? How did you handle it?"* Direct request for community knowledge.
- **Insight** — *"Something clicked for me today about [X]."* Reflection sharing.

Format is suggested, not mandatory at Tier 2. By Tier 3 users naturally self-select toward more useful formats.

---

## Safety Layer

### AI Pre-Moderation (every post, before it's visible)
Posts held for a few seconds before publishing. AI scans for:
- Drug slang and coded language (updated continuously — slang evolves fast)
- Contact sharing: phone numbers, emails, usernames for other platforms
- Buying/selling language patterns
- External links (blocked at Tier 2, AI-reviewed at Tier 3)
- Explicit content
- Doxxing or identifying information about others

**Three outcomes:**
1. Clean → publishes immediately (user experience: instant)
2. Uncertain → held for human review (user sees: "being reviewed")
3. Clear violation → auto-rejected (user sees: "can't post that", no detail given)

No false transparency — users never know which triggered a hold. No gaming the system.

### Hard Rules (always, regardless of tier)
- No sharing contact information publicly ever
- No external platform handles ("DM me on [platform]")
- No location information
- Anonymous usernames by default — no real names
- No photographs that could identify a person

### Community Flagging
- Any user can flag a post
- Three flags from different users → automatic hold pending review
- Tier 3 users carry slightly more weight on flags (they've invested more)
- Repeated false flagging → flag privilege suspended

### Human Moderation (eventual)
AI-only at launch. Human moderation layer added as community grows. Clear escalation path for edge cases AI gets wrong.

---

## Sub-Spaces (Proposed)

Rather than one mixed feed, the community is organized into spaces. Users subscribe to spaces relevant to them.

**Substance-based spaces:**
- Alcohol & drinking
- Opioids & pain management
- Stimulants (meth, cocaine, ADHD medication)
- Cannabis
- Multiple / polysubstance
- Harm reduction (not abstinence-focused)

**Stage-based spaces:**
- First 30 days
- 30–90 days
- 90 days–1 year
- 1 year+
- Long-term recovery (5+ years)

**Program-based spaces:**
- 12-step (AA/NA/GA/etc.)
- SMART Recovery
- No program (building my own path)

**Topic spaces:**
- Mental health + recovery
- Relationships in recovery
- Work and career
- Family and parenting
- Grief and loss
- Daily wins (positivity-focused)

A user subscribes to 2-4 spaces on onboarding. Can change anytime.

---

## Harm Reduction as First-Class Citizen

Harm reduction users have full access on the same earned tier terms. No abstinence requirement.

The harm reduction space within the community is non-judgmental, practical, and focused on reducing risk and chaos — not on convincing people to stop. Naloxone distribution info, safer use practices, honest conversation about managing use.

This is controversial for some 12-step purists. It's also the right thing to do. People in harm reduction are not lesser. Their lives matter.

---

## What Success Looks Like

A year after launch, a newcomer opens the app at midnight feeling completely alone. They scroll the feed and find three posts that describe exactly what they're feeling. They save them all to "For Me". They read the comments. They feel less alone. They go to sleep instead of using.

They don't post anything. They don't tell anyone. But the next day they come back.

That's the Rat Park working.

---

## Open Questions

- [ ] Anonymous usernames: user-chosen or system-generated? (user-chosen = more personal, system-generated = less pressure)
- [ ] Can Tier 1 users see ALL content or are some spaces Tier 2+ only?
- [ ] Is there a "mentor" role for long-term recovery users who want to support newcomers?
- [ ] How does the AI sponsor integrate community content beyond the "For Me" folder? (e.g. surfacing relevant posts proactively)
- [ ] Does the community platform require separate Supabase tables/RLS policies or is it within existing schema?
- [ ] Launch strategy: invite-only first cohort to seed culture before public launch?
