-- ============================================================
-- Migration: Add Missing Tables
-- Date: 2026-03-28
-- Purpose: Add tables referenced in sync_service.dart but missing from initial schema
-- ============================================================

-- ============================================================
-- journal_entries
-- ============================================================
create table if not exists public.journal_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  encrypted_title text,
  encrypted_content text not null,
  encrypted_mood text,
  encrypted_craving text,
  encrypted_tags text,
  is_favorite boolean not null default false,
  encryption_version smallint not null default 1,
  key_id text,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
alter table public.journal_entries enable row level security;
drop policy if exists "journal_entries_select_own" on public.journal_entries;
drop policy if exists "journal_entries_insert_own" on public.journal_entries;
drop policy if exists "journal_entries_update_own" on public.journal_entries;
drop policy if exists "journal_entries_delete_own" on public.journal_entries;
create policy "journal_entries_select_own" on public.journal_entries for
select using (auth.uid() = user_id);
create policy "journal_entries_insert_own" on public.journal_entries for
insert with check (auth.uid() = user_id);
create policy "journal_entries_update_own" on public.journal_entries for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "journal_entries_delete_own" on public.journal_entries for delete using (auth.uid() = user_id);
create index if not exists idx_journal_entries_user_updated on public.journal_entries (user_id, updated_at desc);
create index if not exists idx_journal_entries_user_favorite on public.journal_entries (user_id, is_favorite) where is_favorite = true;

-- ============================================================
-- gratitude_entries
-- ============================================================
create table if not exists public.gratitude_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  encrypted_content text not null,
  encryption_version smallint not null default 1,
  key_id text,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
alter table public.gratitude_entries enable row level security;
drop policy if exists "gratitude_entries_select_own" on public.gratitude_entries;
drop policy if exists "gratitude_entries_insert_own" on public.gratitude_entries;
drop policy if exists "gratitude_entries_update_own" on public.gratitude_entries;
drop policy if exists "gratitude_entries_delete_own" on public.gratitude_entries;
create policy "gratitude_entries_select_own" on public.gratitude_entries for
select using (auth.uid() = user_id);
create policy "gratitude_entries_insert_own" on public.gratitude_entries for
insert with check (auth.uid() = user_id);
create policy "gratitude_entries_update_own" on public.gratitude_entries for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "gratitude_entries_delete_own" on public.gratitude_entries for delete using (auth.uid() = user_id);
create index if not exists idx_gratitude_entries_user_created on public.gratitude_entries (user_id, created_at desc);

-- ============================================================
-- achievements
-- ============================================================
create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  achievement_key text not null,
  achievement_type text not null check (achievement_type in ('milestone', 'streak', 'step_completion')),
  device_id text,
  is_viewed boolean not null default false,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  earned_at timestamptz not null default now()
);
alter table public.achievements enable row level security;
drop policy if exists "achievements_select_own" on public.achievements;
drop policy if exists "achievements_insert_own" on public.achievements;
drop policy if exists "achievements_update_own" on public.achievements;
drop policy if exists "achievements_delete_own" on public.achievements;
create policy "achievements_select_own" on public.achievements for
select using (auth.uid() = user_id);
create policy "achievements_insert_own" on public.achievements for
insert with check (auth.uid() = user_id);
create policy "achievements_update_own" on public.achievements for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "achievements_delete_own" on public.achievements for delete using (auth.uid() = user_id);
create index if not exists idx_achievements_user_earned on public.achievements (user_id, earned_at desc);

-- ============================================================
-- contacts
-- ============================================================
create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  encrypted_name text not null,
  encrypted_phone text not null,
  encrypted_email text,
  relationship text not null check (relationship in ('sponsor', 'sponsee', 'emergency', 'friend', 'family', 'other')),
  is_primary boolean not null default false,
  encryption_version smallint not null default 1,
  key_id text,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
alter table public.contacts enable row level security;
drop policy if exists "contacts_select_own" on public.contacts;
drop policy if exists "contacts_insert_own" on public.contacts;
drop policy if exists "contacts_update_own" on public.contacts;
drop policy if exists "contacts_delete_own" on public.contacts;
create policy "contacts_select_own" on public.contacts for
select using (auth.uid() = user_id);
create policy "contacts_insert_own" on public.contacts for
insert with check (auth.uid() = user_id);
create policy "contacts_update_own" on public.contacts for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "contacts_delete_own" on public.contacts for delete using (auth.uid() = user_id);
create index if not exists idx_contacts_user_relationship on public.contacts (user_id, relationship);

-- ============================================================
-- meetings
-- ============================================================
create table if not exists public.meetings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  name text not null,
  location text not null,
  address text,
  meeting_datetime timestamptz,
  meeting_type text not null check (meeting_type in ('in-person', 'online', 'hybrid')),
  encrypted_formats text,
  encrypted_notes text,
  is_favorite boolean not null default false,
  latitude double precision,
  longitude double precision,
  encryption_version smallint not null default 1,
  key_id text,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
alter table public.meetings enable row level security;
drop policy if exists "meetings_select_own" on public.meetings;
drop policy if exists "meetings_insert_own" on public.meetings;
drop policy if exists "meetings_update_own" on public.meetings;
drop policy if exists "meetings_delete_own" on public.meetings;
create policy "meetings_select_own" on public.meetings for
select using (auth.uid() = user_id or user_id is null);
create policy "meetings_insert_own" on public.meetings for
insert with check (auth.uid() = user_id or user_id is null);
create policy "meetings_update_own" on public.meetings for
update using (auth.uid() = user_id or user_id is null) with check (auth.uid() = user_id or user_id is null);
create policy "meetings_delete_own" on public.meetings for delete using (auth.uid() = user_id or user_id is null);
create index if not exists idx_meetings_user_favorite on public.meetings (user_id, is_favorite) where is_favorite = true;
-- Note: For location-based queries, consider adding a GiST index if using PostGIS
-- create index if not exists idx_meetings_location on public.meetings using gist (ll_to_earth(latitude, longitude));

-- ============================================================
-- safety_plans
-- ============================================================
create table if not exists public.safety_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  encrypted_warning_signs text,
  encrypted_coping_strategies text,
  encrypted_support_contacts text,
  encrypted_professional_contacts text,
  encrypted_safe_environments text,
  encryption_version smallint not null default 1,
  key_id text,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
alter table public.safety_plans enable row level security;
drop policy if exists "safety_plans_select_own" on public.safety_plans;
drop policy if exists "safety_plans_insert_own" on public.safety_plans;
drop policy if exists "safety_plans_update_own" on public.safety_plans;
drop policy if exists "safety_plans_delete_own" on public.safety_plans;
create policy "safety_plans_select_own" on public.safety_plans for
select using (auth.uid() = user_id);
create policy "safety_plans_insert_own" on public.safety_plans for
insert with check (auth.uid() = user_id);
create policy "safety_plans_update_own" on public.safety_plans for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "safety_plans_delete_own" on public.safety_plans for delete using (auth.uid() = user_id);

-- ============================================================
-- challenges
-- ============================================================
create table if not exists public.challenges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null,
  duration_days int not null check (duration_days > 0),
  start_date date not null,
  end_date date,
  is_completed boolean not null default false,
  is_active boolean not null default true,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
alter table public.challenges enable row level security;
drop policy if exists "challenges_select_own" on public.challenges;
drop policy if exists "challenges_insert_own" on public.challenges;
drop policy if exists "challenges_update_own" on public.challenges;
drop policy if exists "challenges_delete_own" on public.challenges;
create policy "challenges_select_own" on public.challenges for
select using (auth.uid() = user_id);
create policy "challenges_insert_own" on public.challenges for
insert with check (auth.uid() = user_id);
create policy "challenges_update_own" on public.challenges for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "challenges_delete_own" on public.challenges for delete using (auth.uid() = user_id);
create index if not exists idx_challenges_user_active on public.challenges (user_id, is_active);

-- ============================================================
-- reading_reflections
-- ============================================================
create table if not exists public.reading_reflections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  reading_id text not null,
  reading_date date not null,
  encrypted_reflection text not null,
  encryption_version smallint not null default 1,
  key_id text,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, reading_id, reading_date)
);
alter table public.reading_reflections enable row level security;
drop policy if exists "reading_reflections_select_own" on public.reading_reflections;
drop policy if exists "reading_reflections_insert_own" on public.reading_reflections;
drop policy if exists "reading_reflections_update_own" on public.reading_reflections;
drop policy if exists "reading_reflections_delete_own" on public.reading_reflections;
create policy "reading_reflections_select_own" on public.reading_reflections for
select using (auth.uid() = user_id);
create policy "reading_reflections_insert_own" on public.reading_reflections for
insert with check (auth.uid() = user_id);
create policy "reading_reflections_update_own" on public.reading_reflections for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "reading_reflections_delete_own" on public.reading_reflections for delete using (auth.uid() = user_id);
create index if not exists idx_reading_reflections_user_date on public.reading_reflections (user_id, reading_date desc);

-- ============================================================
-- daily_inventories (NEW - for Step 10 daily inventory)
-- ============================================================
create table if not exists public.daily_inventories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  inventory_date date not null,
  encrypted_resentful_about text,
  encrypted_selfish_about text,
  encrypted_dishonest_about text,
  encrypted_afraid_of text,
  encrypted_harmed_who text,
  encrypted_kind_and_loving text,
  was_resentful boolean,
  was_selfish boolean,
  was_dishonest boolean,
  was_afraid boolean,
  harmed_anyone boolean,
  showed_kindness boolean,
  encrypted_reflection text,
  mood_rating int check (mood_rating between 1 and 5),
  craving_level int check (craving_level between 0 and 10),
  encryption_version smallint not null default 1,
  key_id text,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, inventory_date)
);
alter table public.daily_inventories enable row level security;
drop policy if exists "daily_inventories_select_own" on public.daily_inventories;
drop policy if exists "daily_inventories_insert_own" on public.daily_inventories;
drop policy if exists "daily_inventories_update_own" on public.daily_inventories;
drop policy if exists "daily_inventories_delete_own" on public.daily_inventories;
create policy "daily_inventories_select_own" on public.daily_inventories for
select using (auth.uid() = user_id);
create policy "daily_inventories_insert_own" on public.daily_inventories for
insert with check (auth.uid() = user_id);
create policy "daily_inventories_update_own" on public.daily_inventories for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "daily_inventories_delete_own" on public.daily_inventories for delete using (auth.uid() = user_id);
create index if not exists idx_daily_inventories_user_date on public.daily_inventories (user_id, inventory_date desc);

-- ============================================================
-- updated_at triggers for new tables
-- ============================================================
do $$
declare tbl text;
begin foreach tbl in array array [
    'journal_entries',
    'gratitude_entries',
    'achievements',
    'contacts',
    'meetings',
    'safety_plans',
    'challenges',
    'reading_reflections',
    'daily_inventories'
  ] loop execute format(
  'drop trigger if exists set_updated_at on public.%I',
  tbl
);
execute format(
  'create trigger set_updated_at
       before update on public.%I
       for each row
       execute function public.update_updated_at()',
  tbl
);
end loop;
end;
$$;

-- ============================================================
-- Seed data for challenges (default challenges for all users)
-- ============================================================
-- Note: These will be created locally by DatabaseService for each user
-- No global seed needed since challenges are user-specific

-- ============================================================
-- End of migration
-- ============================================================
