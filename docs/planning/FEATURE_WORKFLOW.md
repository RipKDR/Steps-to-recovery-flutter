# Feature Workflow: User Journey Maps

> **Document Date:** 2026-04-02  
> **Last Updated:** 2026-04-02  
> **Owner:** Development Team  
> **Status:** Living Document

---

## Overview

This document maps the complete user journey through Steps to Recovery, showing how features connect to form a cohesive recovery operating system.

---

## Day 0: Onboarding Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  1. WELCOME SCREEN                                               │
│  ─────────────────────────────────────────────────────────────   │
│  "Build a life worth staying in"                                 │
│                                                                  │
│  [Get Started]                                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  2. SOBRIETY DATE                                                │
│  ─────────────────────────────────────────────────────────────   │
│  "When did you start your journey?"                              │
│                                                                  │
│  [Date Picker]  [I don't remember exactly]                       │
│                                                                  │
│  → Sets milestone dates (7, 30, 90, 365 days)                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  3. MEET YOUR SPONSOR ⭐ UNIQUE                                  │
│  ─────────────────────────────────────────────────────────────   │
│  "You'll have an AI sponsor who learns about you over time"      │
│                                                                  │
│  Choose your sponsor's name:                                     │
│  [Rex] [Sam] [Jordan] [Custom...]                                │
│                                                                  │
│  Choose their approach:                                          │
│  [Warm] [Direct] [Spiritual] [Tough Love]                        │
│                                                                  │
│  [Continue]                                                      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  4. TIME CAPSULE ⭐ UNIQUE                                       │
│  ─────────────────────────────────────────────────────────────   │
│  "Record a message to your future self"                          │
│                                                                  │
│  "Why are you doing this? What do you want for your life?"       │
│                                                                  │
│  [🎤 Record Voice]  [✏️ Write Note]  [Skip for now →]            │
│                                                                  │
│  → Locks until 30-day milestone                                  │
│  → Becomes powerful emotional hook                               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  5. DAILY REMINDERS                                              │
│  ─────────────────────────────────────────────────────────────   │
│  "When should we check in with you?"                             │
│                                                                  │
│  Morning check-in:  [8:00 AM ▼]                                  │
│  Evening check-in:  [8:00 PM ▼]                                  │
│                                                                  │
│  [Save] → HOME SCREEN                                            │
└─────────────────────────────────────────────────────────────────┘
```

**Metrics to track:**
- Onboarding completion rate (target: >70%)
- Sponsor name customization rate
- Time capsule creation rate

---

## Daily Active Loop

### Morning Check-In (8:00 AM)

```
┌─────────────────────────────────────────────────────────────────┐
│  NOTIFICATION: "Good morning. How are you starting your day?"    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  MORNING INTENTION SCREEN                                        │
│  ─────────────────────────────────────────────────────────────   │
│  "Good morning, H."                                              │
│                                                                  │
│  How are you feeling?                                            │
│  😫 1 ─── 2 ─── 3 ─── 4 ─── 5 😊                                 │
│  [Selected: 3 - Okay]                                            │
│                                                                  │
│  What's one thing you'll do for your recovery today?             │
│  [Text input...]                                                 │
│  "Go to my meeting tonight"                                      │
│                                                                  │
│  [Save]                                                          │
│                                                                  │
│  → Shows streak: "7 days in a row 🔥"                            │
│  → Streak count increments                                       │
└─────────────────────────────────────────────────────────────────┘
```

**Data captured:**
- Mood score (1-5)
- Intention text
- Timestamp
- Streak calculation

---

### Home Screen (Throughout Day)

```
┌─────────────────────────────────────────────────────────────────┐
│  HOME SCREEN                                                     │
│  ═══════════════════════════════════════════════════════════   │
│                                                                  │
│  ┌─────────────────────────────────────┐                        │
│  │  🔥 34 days sober                   │                        │
│  │  "One day at a time"                │                        │
│  │  Next milestone: 60 days (26 away)  │                        │
│  └─────────────────────────────────────┘                        │
│                                                                  │
│  ⚡ QUICK ACTIONS:                                               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐            │
│  │ 🌊       │ │ 📝       │ │ 👤       │ │ 📍       │            │
│  │  The     │ │ Journal  │ │  Call    │ │  Find    │            │
│  │  Pause   │ │          │ │ Sponsor  │ │ Meeting  │            │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘            │
│                                                                  │
│  📊 TODAY'S STATUS:                                              │
│  ✅ Morning check-in (Mood: 3)                                   │
│  ⏳ Evening check-in (Due: 8:00 PM)                              │
│  🔄 Step 4 in progress (Inventory)                               │
│                                                                  │
│  ┌─────────────────────────────────────┐ ⭐ UNIQUE              │
│  │  👤 SPONSOR CARD                     │                        │
│  │  ─────────────────                  │                        │
│  │  "Rex noticed you've been checking  │                        │
│  │   in consistently. They're here     │                        │
│  │   if you need them."                │                        │
│  │                                      │                        │
│  │   [Talk to Rex →]                   │                        │
│  └─────────────────────────────────────┘                        │
│                                                                  │
│  📅 UPCOMING:                                                    │
│  • 30-day milestone in 2 days                                    │
│  • Meeting tonight at 7:00 PM                                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Interaction points:**
- Quick actions for immediate needs
- Sponsor card for emotional support
- Status tracking for accountability
- Upcoming events for planning

---

### Craving Hits: The Pause

```
┌─────────────────────────────────────────────────────────────────┐
│  USER OPENS APP → Taps "The Pause" or high craving detected      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  THE PAUSE SCREEN ⭐ UNIQUE                                      │
│  ═══════════════════════════════════════════════════════════   │
│                                                                  │
│  ┌─────────────────────────────────────┐                        │
│  │                                     │                        │
│  │         🌊  90 seconds              │                        │
│  │                                     │                        │
│  │      [Breathing animation]          │                        │
│  │                                     │                        │
│  │     ○  ○  ●  ○  ○  ○  ○  ○  ○      │  ← Progress dots       │
│  │                                     │                        │
│  │   "This urge will peak and fade.   │                        │
│  │    You just need to wait it out."  │                        │
│  │                                     │                        │
│  │   [Skip button DISABLED]            │                        │
│  │                                     │                        │
│  └─────────────────────────────────────┘                        │
│                                                                  │
│  30 seconds: "You're doing great. Keep breathing."               │
│  60 seconds: "The worst is passing. Hold on."                    │
│  90 seconds: "You surfed that urge."                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  SUCCESS SCREEN                                                  │
│  ─────────────────────────────────────────────────────────────   │
│                                                                  │
│  🎉 You surfed that craving!                                     │
│                                                                  │
│  "The urge peaked at 8/10 and you rode it out.                   │
│   That's real strength."                                         │
│                                                                  │
│  [Save this win]  [Talk to Rex about it]                         │
│                                                                  │
│  → Adds to Tiny Wins log                                         │
│  → Increases "urges surfed" streak                               │
└─────────────────────────────────────────────────────────────────┘
```

**Science behind The Pause:**
- Urges peak at 20-30 minutes and fade naturally
- Most relapses happen in first 90 seconds of decision
- Forced wait creates biological window for urge to pass

**Metrics:**
- The Pause usage rate (target: 1+ per week per user)
- Completion rate (should be 100% - no skip)
- Save rate to Tiny Wins

---

### Evening Check-In (8:00 PM)

```
┌─────────────────────────────────────────────────────────────────┐
│  NOTIFICATION: "Time for your evening check-in"                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  EVENING PULSE SCREEN                                            │
│  ─────────────────────────────────────────────────────────────   │
│                                                                  │
│  "How was your day?"                                             │
│                                                                  │
│  Mood: 😫 1 ─── 2 ─── 3 ─── 4 ─── 5 😊                          │
│  [Selected: 4]                                                   │
│                                                                  │
│  Craving level:                                                  │
│  😌 1 ─── 2 ─── 3 ─── 4 ─── 5 ─── 6 ─── 7 ─── 8 ─── 9 ─── 10 😫 │
│  [Selected: 3]                                                   │
│                                                                  │
│  Did you use today? [No ✅] [Yes]                                │
│                                                                  │
│  ─────────────────────────────────────────────────────────────   │
│                                                                  │
│  If YES selected:                                                │
│  "Thanks for being honest. This helps us both understand         │
│   your patterns better. No judgment here."                       │
│                                                                  │
│  What happened? [Optional]                                       │
│  [Text input...]                                                 │
│                                                                  │
│  [Save]                                                          │
└─────────────────────────────────────────────────────────────────┘
```

**Triggers based on input:**

| Input | Trigger | Action |
|-------|---------|--------|
| Craving ≥ 8 OR Mood = 1 | High risk detected | Sponsor badge appears |
| Craving ≥ 8 | Immediate intervention | Offer "The Pause" |
| "Yes" to using | Relapse event | Non-judgmental logging + support options |
| Mood < 3 | Low mood pattern | Suggest journal or sponsor chat |

**Sponsor badge appears:**
```
┌─────────────────────────────────────────────────────────────────┐
│  PROFILE TAB (amber dot appears)                                 │
│                                                                  │
│  "Rex noticed your check-in. They're here."                     │
│                                                                  │
│  Tap → Opens sponsor chat:                                       │
│  "You reported a high craving today. Want to talk about it?"    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Weekly Engagement Loop

### Sunday Evening Review

```
┌─────────────────────────────────────────────────────────────────┐
│  WEEKLY REVIEW SCREEN                                            │
│  ═══════════════════════════════════════════════════════════   │
│                                                                  │
│  Your Week at a Glance                                           │
│  March 24-30, 2026                                               │
│                                                                  │
│  ┌─────────────────────────────────────┐                        │
│  │  Mood This Week                      │                        │
│  │  [Line chart: Mon Tue Wed Thu Fri]   │                        │
│  │  5 ┤        ╭─╮                       │                        │
│  │  4 ┤  ╭────╯  ╰──╮                    │                        │
│  │  3 ┤──╯          ╰────                │                        │
│  │     Mon Tue Wed Thu Fri              │                        │
│  └─────────────────────────────────────┘                        │
│                                                                  │
│  ┌─────────────────────────────────────┐                        │
│  │  Cravings This Week                  │                        │
│  │  [Line chart with baseline]          │                        │
│  │  Average: 4.2 (below your baseline)  │                        │
│  └─────────────────────────────────────┘                        │
│                                                                  │
│  📊 INSIGHTS:                                                    │
│  • Hardest day: Thursday (work stress)                           │
│  • Best day: Saturday (meeting + rest)                           │
│  • Check-in streak: 12 days 🔥                                   │
│                                                                  │
│  👤 REX'S OBSERVATION: ⭐ UNIQUE                                 │
│  "I noticed your mood drops on workdays. Want to look at         │
│   that pattern together?"                                        │
│                                                                  │
│  [Talk to Rex] [Dismiss]                                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Step Work Flow

### Step 4: Inventory Example

```
┌─────────────────────────────────────────────────────────────────┐
│  STEP 4: INVENTORY                                               │
│  ═══════════════════════════════════════════════════════════   │
│                                                                  │
│  Who are you resentful at?                                       │
│  [Text input...]                                                 │
│  "My boss for passing me over for promotion"                     │
│                                                                  │
│  ─────────────────────────────────────────────────────────────   │
│                                                                  │
│  The cause:                                                      │
│  "What specifically did they do?"                                │
│  [Text input...]                                                 │
│                                                                  │
│  ─────────────────────────────────────────────────────────────   │
│                                                                  │
│  Affects my:                                                     │
│  [ ] Self-esteem    [ ] Security    [ ] Ambitions               │
│  [ ] Personal relations    [X] Sex relations                    │
│                                                                  │
│  ─────────────────────────────────────────────────────────────   │
│                                                                  │
│  What part did you play?                                         │
│  "I didn't speak up when I had the chance..."                    │
│  [Text input...]                                                 │
│                                                                  │
│  [Save Progress]  [Talk to Rex about this →]                     │
│                                                                  │
│  → Progress saved to encrypted storage                           │
│  → Syncs to Supabase when online (if enabled)                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Milestone Celebration Flow

### Day 30: Milestone Hit

```
┌─────────────────────────────────────────────────────────────────┐
│  🎉 FULL-SCREEN CELEBRATION (auto-triggered on app open)         │
│  ═══════════════════════════════════════════════════════════   │
│                                                                  │
│  [Confetti animation falling]                                    │
│                                                                  │
│         ┌──────────┐                                             │
│         │   30     │  ← Animated counter: 0 → 30                 │
│         │   days   │                                             │
│         └──────────┘                                             │
│                                                                  │
│  "30 Days - One Month"                                           │
│                                                                  │
│  "One month ago, you decided to change your life.                │
│   You've shown up every day since."                              │
│                                                                  │
│  ┌─────────────────────────────────────┐                        │
│  │  [Share my milestone]               │                        │
│  │  Generates PNG share card           │                        │
│  └─────────────────────────────────────┘                        │
│                                                                  │
│  [Continue]                                                      │
│                                                                  │
│  → Marks celebration as seen (won't repeat)                    │
│  → Triggers Time Capsule unlock if applicable                    │
└─────────────────────────────────────────────────────────────────┘
```

**Share Card:**
```
┌─────────────────────────────────────┐
│                                     │
│     Steps to Recovery               │
│                                     │
│         🎉                          │
│                                     │
│      30 Days                        │
│      One Month                      │
│                                     │
│   "One day at a time"               │
│                                     │
│   stepstorecovery.app               │
│                                     │
└─────────────────────────────────────┘
```

---

### Time Capsule Unlock

```
┌─────────────────────────────────────────────────────────────────┐
│  ⏳ TIME CAPSULE UNLOCKED                                        │
│  ═══════════════════════════════════════════════════════════   │
│                                                                  │
│  "You have a message from yourself, 30 days ago."                │
│                                                                  │
│  ┌─────────────────────────────────────┐                        │
│  │  🎤 Voice Message                     │                        │
│  │                                      │                        │
│  │  [Play button] 0:32                  │                        │
│  │                                      │                        │
│  │  "Hey... it's me on day 1. I'm       │                        │
│  │   scared but I'm doing this. I       │                        │
│  │   want my life back..."              │                        │
│  └─────────────────────────────────────┘                        │
│                                                                  │
│  Emotional impact: HIGH                                          │
│  → Reinforces progress                                           │
│  → Reminds user why they started                                 │
│  → Deep engagement hook                                          │
│                                                                  │
│  [Record new time capsule for 90 days]                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Relapse Prevention Workflow

### Scenario: User Reports Use

```
┌─────────────────────────────────────────────────────────────────┐
│  USER SELECTS "YES" TO "Did you use today?"                      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  1. IMMEDIATE RESPONSE (non-judgmental)                          │
│  ─────────────────────────────────────────────────────────────   │
│  "Thanks for being honest. This data helps us both understand    │
│   your patterns better."                                         │
│                                                                  │
│  ❌ No streak reset shame                                        │
│  ❌ No "start over" language                                     │
│  ✅ Progress continues                                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  2. IMMEDIATE SUPPORT OPTIONS                                    │
│  ─────────────────────────────────────────────────────────────   │
│                                                                  │
│  What do you need right now?                                     │
│                                                                  │
│  [🤖 Talk to Rex]     [📞 Call your sponsor]                     │
│  [📍 Find a meeting]  [🌊 Start The Pause]                       │
│                                                                  │
│  Or tell me what happened:                                       │
│  [Text input...]                                                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  3. PATTERN DETECTION (if data available)                        │
│  ─────────────────────────────────────────────────────────────   │
│                                                                  │
│  "This is the 3rd Thursday this month. Pattern worth noting."   │
│                                                                  │
│  → No judgment                                                    │
│  → Data collection for future prevention                         │
│  → Sponsor learns user's specific triggers                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  4. FOLLOW-UP (next morning)                                     │
│  ─────────────────────────────────────────────────────────────   │
│                                                                  │
│  Notification: "How are you feeling this morning? No judgment." │
│                                                                  │
│  → Continues support                                             │
│  → Doesn't avoid the topic                                       │
│  → Normalizes honesty                                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Sponsor Memory Workflow (Internal)

### How the Sponsor Learns

```
┌─────────────────────────────────────────────────────────────────┐
│  MEMORY TIER ARCHITECTURE                                        │
│  ═══════════════════════════════════════════════════════════   │
│                                                                  │
│  TIER 1: SESSION MEMORY (current conversation)                   │
│  ─────────────────────────────────────────────────────────────   │
│  User: "I'm stressed about work"                                 │
│  Sponsor: "What's stressing you?"                                │
│  User: "Big presentation tomorrow"                               │
│  → Stored for this conversation only                            │
│  → Cleared when chat ends                                        │
│                                                                  │
│  TIER 2: DIGEST MEMORY (up to 20 items)                          │
│  ─────────────────────────────────────────────────────────────   │
│  • "Works in software"                                           │
│  • "Struggles with Thursdays"                                    │
│  • "Big presentation = high stress"                              │
│  • "Has a cat named Mittens"                                     │
│  → Referenced in next few conversations                          │
│  → Expires after ~10 days if not reinforced                      │
│                                                                  │
│  TIER 3: LONG-TERM MEMORY (up to 50 distilled facts)             │
│  ─────────────────────────────────────────────────────────────   │
│  • "Father passed away 2 years ago - unresolved grief"           │
│  • "Primary trigger: work presentations"                         │
│  • "Lives alone, limited support network"                        │
│  • "Struggles with self-worth"                                   │
│  → Referenced in ALL conversations                               │
│  → Core identity of the user                                     │
│  → Promoted from digest after repeated mention                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Relationship Stage Progression

```
┌─────────────────────────────────────────────────────────────────┐
│  STAGE        │ DAYS    │ BEHAVIOR                              │
│  ─────────────┼─────────┼──────────────────────────────────────│
│  New          │ 0-7     │ Surface level, building trust         │
│               │         │ Generic supportive responses          │
│               │         │ Heavy use of open questions           │
├───────────────┼─────────┼──────────────────────────────────────┤
│  Building     │ 8-30   │ Starting to personalize               │
│               │         │ References recent conversations       │
│               │         │ Learns communication style            │
├───────────────┼─────────┼──────────────────────────────────────┤
│  Trusted      │ 31-90  │ References past conversations         │
│               │         │ Notices patterns in user behavior     │
│               │         │ Offers specific suggestions           │
├───────────────┼─────────┼──────────────────────────────────────┤
│  Close        │ 91-365 │ Deep pattern recognition              │
│               │         │ Knows user's history intimately       │
│               │         │ Can predict vulnerability windows     │
├───────────────┼─────────┼──────────────────────────────────────┤
│  Deep         │ 365+   │ Fully personalized                    │
│               │         │ Years of context                      │
│               │         │ True sponsor relationship             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Feature Dependencies Map

```
┌─────────────────────────────────────────────────────────────────┐
│  FOUNDATION LAYER                                                │
│  ─────────────────────────────────────────────────────────────   │
│  • EncryptionService          • DatabaseService                  │
│  • PreferencesService         • NotificationService              │
│  • AppStateService            • ConnectivityService              │
│                                                                  │
│         ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓                                       │
│                                                                  │
│  DATA LAYER                                                      │
│  ─────────────────────────────────────────────────────────────   │
│  • Journal persistence        • Gratitude persistence            │
│  • Inventory persistence      • Check-in storage                 │
│  • Step work progress         • Milestone tracking               │
│                                                                  │
│         ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓                                       │
│                                                                  │
│  SPONSOR LAYER ⭐                                                │
│  ─────────────────────────────────────────────────────────────   │
│  • SponsorMemoryStore         • ContextAssembler                 │
│  • SponsorService             • Relationship stages              │
│  • Behavioral signals         • Proactive hooks                  │
│                                                                  │
│         ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓                                       │
│                                                                  │
│  INTERVENTION LAYER                                              │
│  ─────────────────────────────────────────────────────────────   │
│  • The Pause                  • Pattern detection                │
│  • Tiny Wins log              • Time Capsule                     │
│                                                                  │
│         ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓                                       │
│                                                                  │
│  ENGAGEMENT LAYER                                                │
│  ─────────────────────────────────────────────────────────────   │
│  • Progress charts            • Mindfulness library              │
│  • Milestone celebrations     • Viral sharing                    │
│  • Weekly reviews                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Metrics to Track at Each Stage

| Stage | Metric | Target | Why |
|-------|--------|--------|-----|
| **Onboarding** | Completion rate | >70% | Foundation for retention |
| | Time to complete | <5 min | Friction reduction |
| | Sponsor customization | >50% | Personalization signal |
| **Daily** | Day 7 retention | >40% | Habit formation |
| | Day 30 retention | >20% | Industry benchmark |
| | Sponsor chat opens | 2+ per week | Core engagement |
| **Check-ins** | Morning completion | >60% | Morning habit |
| | Evening completion | >50% | Evening habit |
| | Streak length | 7+ days | Habit strength |
| **Intervention** | The Pause usage | 1+ per week | Relapse prevention |
| | Urge surf success | >80% | Tool effectiveness |
| | Tiny Wins logged | 3+ per week | Positive reinforcement |
| **Milestones** | 7-day celebration | >90% | Early win |
| | 30-day celebration | >70% | Retention signal |
| | Share rate | >20% | Viral coefficient |

---

## Document History

| Date | Author | Change |
|------|--------|--------|
| 2026-04-02 | Kimi | Initial workflow documentation |
