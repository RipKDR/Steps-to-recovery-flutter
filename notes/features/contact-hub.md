# Contact Hub — Recovery Network Management
*Feature concept — 2026-03-22 — Status: Brainstorming*

---

## What It Is

A curated contact list specifically for the user's recovery network — separate from their phone's general contacts. Sponsors, sponsees, home group members, accountability partners, people from meetings, sober friends, therapists, trusted family.

It's the infrastructure for human connection. The Rat Park needs real people in it. This is where they live.

---

## Why Not Just Use the Phone's Contacts?

1. **Recovery contacts need context.** A phone contact is a name and number. A recovery contact is "my sponsor, who I met in the Tuesday Bondi NA meeting, who I call when I'm struggling on weekends."

2. **Privacy.** Some users separate their recovery life from their wider life. They don't want their sponsor in the same contacts list as their boss.

3. **The AI needs to know who these people are.** The sponsor can say *"You haven't talked to Marcus in 11 days — that's the longest gap in three months. What's going on?"* It can't do that if Marcus is just a phone number.

4. **The Crisis Bridge needs names.** The 3am emergency bridge (AI drafts a message) works so much better when it knows: *"Your sponsor is David. Last contact: 6 days ago. Draft a message to David?"* rather than *"Add an emergency contact."*

---

## Contact Types

Each contact has a type that shapes how the AI uses them:

| Type | Description | AI Uses |
|---|---|---|
| **Sponsor** | Primary recovery support person | Crisis bridge first call, isolation detection |
| **Sponsee** | Someone the user sponsors | Service/purpose tracking (Rat Park meaning) |
| **Accountability Partner** | Peer check-in partner | Regular contact tracking |
| **Home Group** | Regular meeting attendance group | Meeting streak, belonging |
| **Sober Friend** | Someone in recovery they connect with | Social connection tracking |
| **Therapist / Counsellor** | Professional support | Professional support tracking |
| **Trusted Family / Friend** | Non-recovery network but trusted | Broader support circle |
| **NA/AA Member** | General fellowship connection | Meeting network |

---

## How People Build Their Contact Hub

### From Meetings (Primary Use Case)
The main entry point: *"You just came out of a meeting. Did you get any numbers?"*

A quick add flow:
1. Tap "Add contact from meeting"
2. Name + phone number
3. Which meeting / where you met them
4. Contact type (auto-suggested based on context)
5. Optional: how they could help ("good to call when I'm isolating")

This captures the moment — after a meeting when you've got their number in your hand. That moment usually evaporates by the time you get home.

### From Phone Contacts (Import)
Users can import specific contacts from their phone and tag them as recovery contacts. Not a bulk import — deliberate selection. *"Choose contacts to add to your recovery network."*

### Manually Added
Name, number, type, notes. Clean and simple.

---

## What the AI Does With This

### Isolation Detection
The AI tracks recency of real human contact. If a user hasn't contacted anyone from their hub in 3+ days, the sponsor notices:
- *"You haven't reached out to anyone from your network this week. How are you doing?"*
- At 7 days: more direct. *"Seven days without contacting anyone in your recovery network. That's a pattern we've talked about. Who could you send one message to right now?"*

### Proactive Suggestions
- Before a hard milestone (Friday evening, known high-risk time): *"Tonight has been tough for you lately. Is there someone from your network you could plan to talk to?"*
- Before a milestone anniversary: *"Your 90-day mark is in 3 days. Who do you want to share that with?"*
- After a slip: *"What's one person from your network you could reach out to today?"*

### Crisis Bridge
When the AI detects crisis, it offers specific names:
- *"Do you want me to help you reach out to David right now? I can draft a message."*
- Not generic: "contact your sponsor" but *"reach out to David"* — the person has a name, the request has weight.

### Relationship Health Tracking (Private, Not Shown)
The AI internally tracks:
- Frequency of contact with each person
- Who the user reaches out to vs who reaches out to them
- Whether the support network is growing or contracting over time
- Whether certain contacts are associated with high-risk patterns (noted, never flagged publicly)

---

## Privacy Architecture

- Contact Hub data is stored locally + optionally synced (with encryption)
- Phone numbers are never sent to AI providers — only the person's name and relationship type
- The AI knows "your sponsor David" not "David's phone number is 0412..."
- Users can remove anyone from the hub at any time
- No notifications sent to contacts without user action

---

## Connection to Community Platform

When someone earns Tier 3 in the community (30 days + contact established), that contact must be in the Contact Hub. This ties the community access system to real-world connection building.

The community platform can surface: *"There are 3 people in the Sydney NA community who use this app. Want to connect?"* — but only as a suggestion, only with consent, and only at Tier 3.

---

## Meeting QR Code Integration (Future)

At meetings, a trusted member could display a QR code. Scanning adds the meeting to your hub and shows who else from the app is a member (if they've opted in). Lightweight, privacy-first version of a meeting management system.

---

## Open Questions

- [ ] Does the Contact Hub replace or supplement the existing sponsor/contacts features in the app?
- [ ] How does emergency contact designation work? (one contact designated for crisis bridge auto-draft)
- [ ] Should the hub have a "Recently Added" nudge for people to actually use numbers they collected?
- [ ] Integration with the phone's native calling/messaging? (tap a contact → calls them directly)
- [ ] Group messaging to multiple hub contacts? (e.g. "I'm struggling tonight" to 3 people at once)
