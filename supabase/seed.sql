-- ============================================================
-- Seed Data for Development
-- Purpose: Provide test data for local development
-- ============================================================

-- ============================================================
-- Test User Account
-- Email: test@example.com
-- Password: TestPassword123!
-- Note: Create via Supabase Auth UI or API, not here
-- ============================================================

-- ============================================================
-- Sample Meetings (AA/NA meetings)
-- ============================================================
INSERT INTO public.meetings (
  id,
  user_id,
  name,
  location,
  address,
  meeting_datetime,
  meeting_type,
  encrypted_formats,
  encrypted_notes,
  is_favorite,
  latitude,
  longitude,
  created_at,
  updated_at
) VALUES
  (
    'meeting-seed-1',
    NULL, -- Global meeting (no user_id)
    'Morning Serenity Group',
    'Community Center',
    '123 Recovery Lane, Sydney NSW 2000',
    '2026-03-28 07:00:00+00',
    'in-person',
    'Discussion, Open',
    'Wheelchair accessible. Coffee before the meeting.',
    false,
    -33.8688,
    151.2093,
    now(),
    now()
  ),
  (
    'meeting-seed-2',
    NULL,
    'Sunset NA Meeting',
    'Hope Church Hall',
    '456 Clean Street, Melbourne VIC 3000',
    '2026-03-28 19:00:00+00',
    'hybrid',
    'Speaker, Step Study',
    'Online link: zoom.us/j/example',
    false,
    -37.8136,
    144.9631,
    now(),
    now()
  ),
  (
    'meeting-seed-3',
    NULL,
    'Online Early Birds',
    'Zoom',
    'Online Meeting',
    '2026-03-28 06:00:00+00',
    'online',
    'Discussion, Beginners',
    'Daily meeting, 30 minutes',
    false,
    NULL,
    NULL,
    now(),
    now()
  ),
  (
    'meeting-seed-4',
    NULL,
    'Weekend Warriors',
    'Recovery Center',
    '789 Sobriety Blvd, Brisbane QLD 4000',
    '2026-03-29 10:00:00+00',
    'in-person',
    'Discussion, Open',
    'Great for newcomers. Childcare available.',
    false,
    -27.4698,
    153.0251,
    now(),
    now()
  ),
  (
    'meeting-seed-5',
    NULL,
    'Candlelight Reflections',
    'Serenity House',
    '321 Peace Ave, Perth WA 6000',
    '2026-03-28 20:00:00+00',
    'in-person',
    'Meditation, Candlelight',
    'Bring a candle. Quiet reflection at the end.',
    false,
    -31.9505,
    115.8605,
    now(),
    now()
  );

-- ============================================================
-- Sample Challenge Templates
-- Note: Challenges are typically created per-user by DatabaseService
-- These are examples only
-- ============================================================
-- INSERT INTO public.challenges (...) -- Not needed - created locally

-- ============================================================
-- Sample Crisis Resources
-- Note: These are typically hardcoded in the app, not in database
-- ============================================================

-- ============================================================
-- Sample Daily Readings
-- Note: Readings are typically hardcoded or in a separate content file
-- ============================================================

-- ============================================================
-- End of seed data
-- ============================================================
