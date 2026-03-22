# Notes — Steps to Recovery
*Running brainstorm folder. Every idea, plan, and thought captured here.*
*Last updated: 2026-03-22*

Add to it. Never delete old entries — just add sections with dates. Reference freely in future sessions.

---

## Folder Structure

```
notes/
├── README.md                            ← you are here (index + decisions)
├── philosophy/
│   ├── rat-park-foundation.md           ← core product philosophy, mission, who it's for
│   └── sponsor-soul-document.md        ← H's frameworks, the AI's worldview, EQ building
├── features/
│   ├── living-ai-sponsor.md             ← full AI sponsor design (memory, stages, crisis, API)
│   ├── community-platform.md            ← Rat Park social layer, tiers, safety, sub-spaces
│   ├── eq-builder.md                    ← EQ development through conversation (new)
│   ├── rat-park-builder-feature.md      ← "Build Your Rat Park" life environment visual (new)
│   ├── contact-hub.md                   ← recovery network management (new)
│   ├── harm-reduction.md                ← harm reduction as first-class citizen (new)
│   ├── original-ideas.md                ← The Pause, Pattern Alerts, Time Capsule, widgets
│   └── todays-standard.md              ← home screen widgets, shortcuts, Health integration
├── gap-analysis/
│   └── rn-vs-flutter.md                 ← reference RN app vs Flutter — what's missing + priority
├── onboarding/
│   └── non-addict-onboarding.md        ← full onboarding flow, 5 user types, screen-by-screen
└── architecture/
    └── scaffold-review.md               ← H's scaffold reviewed, keep/replace decisions
```

---

## Key Decisions Made (Non-Negotiable)

| Decision | Choice |
|---|---|
| **Product mission** | Rat Park builder — not a sobriety tracker |
| **Who it's for** | Anyone whose cage got too small — harm reduction compatible, not 12-step exclusive |
| **AI sponsor data access** | Hybrid — aggregated signals, never raw journal/stepwork text |
| **Sponsor identity** | User-named + chosen vibe at setup, adapts over time |
| **Sponsor memory** | Three tiers: session → daily digest → long-term distilled |
| **Proactive behavior** | Behavioral drift alerts always on, scheduled touchpoints opt-in, user-controlled cap |
| **Community access** | Three earned tiers: Observer → Contributor (7d) → Connected (30d) |
| **Community safety** | AI pre-moderation, no contact sharing, no external handles, sub-spaces |
| **Harm reduction** | Same access, no abstinence requirement, dedicated community space |
| **Onboarding framing** | "What are you working through?" — open, Rat Park from minute one |
| **Sobriety counter** | Opt-in, reframeable, not shown by default on harm reduction path |
| **Architecture** | Flutter singleton services + SponsorService → Recovery API → OpenClaw |
| **State management** | Keep existing singletons, NO Riverpod |
| **Guardrails** | Invisible character traits, not legal disclaimers |
| **H's frameworks** | ACT, CBT, DBT, Jung, Maté = the AI's soul, not just AOD research |

---

## Features by Status

| Feature | Status | Notes file |
|---|---|---|
| Living AI Sponsor | Design approved, spec not written | `features/living-ai-sponsor.md` |
| Community Platform | Brainstorming | `features/community-platform.md` |
| EQ Builder (embedded) | Concept, not specced | `features/eq-builder.md` |
| Rat Park Builder visual | Concept, not specced | `features/rat-park-builder-feature.md` |
| Contact Hub | Concept, not specced | `features/contact-hub.md` |
| Harm Reduction mode | Concept, not specced | `features/harm-reduction.md` |
| Viral Loop (milestones) | Plan ready to execute | `docs/superpowers/plans/2026-03-22-viral-loop.md` |
| The Pause | Idea, not specced | `features/original-ideas.md` |
| Home Screen Widget | Idea, not specced | `features/original-ideas.md` |
| Mindfulness | Gap from RN app | `gap-analysis/rn-vs-flutter.md` |
| Progress Dashboard | Gap from RN app | `gap-analysis/rn-vs-flutter.md` |
| Gratitude (complete) | Quick win gap | `gap-analysis/rn-vs-flutter.md` |
| Inventory (complete) | Quick win gap | `gap-analysis/rn-vs-flutter.md` |

---

## Open Questions (Unresolved)

1. **Onboarding**: Does the app ever explicitly ask about substance use, or wait for user to bring it up?
2. **Community**: Sub-spaces vs mixed feed? Launch strategy (invite-only first cohort)?
3. **Rat Park Builder**: Screen of its own vs woven into home dashboard? Visual metaphor (park / web / house)?
4. **Contact Hub**: Does this replace or extend the existing contacts feature?
5. **Harm Reduction**: Does app offer specific HR resources (naloxone locators, fentanyl strips)?
6. **Slip Protocol**: Dedicated "I slipped" flow or handled by AI sponsor contextually?
7. **Supporting Someone Else**: Is there an onboarding path for partners/parents of people struggling?

---

## Key Reference Projects

- **Reference RN app**: `C:\Users\H\Steps-to-recovery\` — fully featured React Native version to port from
- **H's scaffold**: `C:\Users\H\Downloads\steps_to_recovery_flutter_scaffold.zip` — architecture blueprint for AI sponsor
- **OpenClaw**: `C:\Users\H\.openclaw\` — agent framework, memory system, identity model = inspiration for AI sponsor
