# Steps to Recovery - Flutter

A privacy-first recovery companion app built with Flutter, based on the React Native reference project.

## Overview

This Flutter application recreates the functionality of the Steps to Recovery app (originally built with React Native + Expo) for 12-step recovery programs. The app provides:

- **Daily Check-ins**: Morning intention and evening pulse tracking
- **12 Step Work**: Guided questions and reflections for each step
- **Journal**: Encrypted journal entries with mood tracking
- **Meeting Finder**: Find and track recovery meetings
- **AI Companion**: Conversational support for your recovery journey
- **Crisis Support**: Emergency contacts, intervention tools, and craving management
- **Progress Tracking**: Sobriety counter, mood trends, and achievements
- **Safety Plan**: Personal crisis prevention planning
- **Gratitude Journal**: Daily gratitude practice
- **Personal Inventory**: Step 10 daily inventory
- **Daily Readings**: Inspirational readings with reflections

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants, step prompts
│   ├── models/          # Database models and enums
│   ├── services/        # Encryption, database services
│   ├── theme/           # Design system (colors, typography, spacing)
│   └── utils/           # Utility functions
├── features/
│   ├── ai_companion/    # AI chat feature
│   ├── auth/            # Login, signup screens
│   ├── challenges/      # Recovery challenges
│   ├── craving_surf/    # Craving management
│   ├── crisis/          # Emergency, before you use
│   ├── emergency/       # Danger zone, crisis tools
│   ├── gratitude/       # Gratitude journal
│   ├── home/            # Home dashboard, check-ins
│   ├── inventory/       # Step 10 inventory
│   ├── journal/         # Journal list and editor
│   ├── meetings/        # Meeting finder and details
│   ├── onboarding/      # First-time user experience
│   ├── profile/         # User profile and settings
│   ├── progress/        # Progress dashboard
│   ├── readings/        # Daily readings
│   ├── safety_plan/     # Safety plan builder
│   ├── sponsor/         # Sponsor management
│   └── steps/           # 12-step work screens
├── navigation/          # GoRouter setup, shell screen
├── widgets/             # Reusable widgets
└── main.dart            # App entry point
```

## Design System

The app uses a dark theme with amber accent colors:

- **Background**: True black (#0A0A0A)
- **Primary Accent**: Amber (#F59E0B)
- **Semantic Colors**: Surface, text, and intent tokens
- **Typography**: Inter font family
- **Spacing**: 4px grid-based scale
- **Accessibility**: Minimum 44pt touch targets

## Features

### Core Features (Implemented)

1. **Home Dashboard**
   - Sobriety counter
   - Quick actions
   - Morning/Evening check-in cards

2. **Journal**
   - Create/edit encrypted entries
   - Mood and craving tracking
   - Tags and favorites

3. **12 Steps**
   - Step overview with progress
   - Guided questions for each step
   - Answer review and sharing

4. **Meetings**
   - Meeting finder with filters
   - Meeting details
   - Favorites management

5. **Crisis Support**
   - Emergency contacts
   - Before You Use (5-minute intervention)
   - Craving Surf (breathing exercise)
   - Danger Zone (risky contacts)

6. **AI Companion**
   - Chat interface
   - Quick action prompts
   - Recovery-focused support

7. **Progress**
   - Sobriety milestones
   - Mood trends
   - Statistics and achievements

8. **Profile**
   - User settings
   - Sponsor management
   - Security settings

### Additional Features

- Gratitude journal
- Personal inventory (Step 10)
- Safety plan builder
- Daily readings
- Recovery challenges
- Onboarding flow
- Authentication screens

## Getting Started

### Prerequisites

- Flutter SDK 3.11.0 or higher
- Dart SDK
- Android Studio / Xcode for platform-specific development

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Configuration

The app uses the following services:
- **Local Database**: Isar for offline-first storage
- **Encryption**: AES-256 for sensitive data
- **AI**: Google Generative AI (configurable)
- **Auth**: Supabase (optional)

## Security & Privacy

- All sensitive data is encrypted at rest
- Biometric authentication support
- Offline-first architecture
- No analytics tracking recovery status
- Zero-knowledge architecture option

## Architecture

The app follows a feature-first architecture:
- Each feature is self-contained
- Shared services in `core/`
- GoRouter for navigation
- Riverpod for state management (optional)

## Differences from Reference Project

This Flutter implementation:
- Uses Isar instead of SQLite/Drizzle
- Uses GoRouter instead of React Navigation
- Uses Flutter's Material 3 design system
- Maintains the same feature set and UX
- Preserves all 12-step prompts and content

## Development Status

This is a complete recreation of the reference app's features. Some items that may need additional work:

- Supabase backend integration
- AI companion backend (edge functions)
- Push notifications setup
- Real device testing
- Meeting data source integration

## License

MIT License - See reference project for details

## Safety Notice

This app is meant to support recovery, not replace professional care, therapy, crisis services, or emergency services.

If someone is in immediate danger, contact local emergency services first.
