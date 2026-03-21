-- Steps to Recovery: Initial Supabase Schema
-- All sensitive fields store client-side encrypted ciphertext (AES-256-CBC).
-- The server never sees plaintext recovery data.

-- ============================================================
-- profiles (public metadata only — no sensitive content)
-- ============================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  program_type text,
  sobriety_start_date timestamptz,
  display_name text,
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can view own profile"
  on public.profiles for select using (auth.uid() = id);
create policy "Users can insert own profile"
  on public.profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = id);

-- ============================================================
-- check_ins (encrypted blobs)
-- ============================================================
create table if not exists public.check_ins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  check_in_type text not null, -- 'morning' | 'evening'
  check_in_date date not null,
  encrypted_data text not null, -- client-encrypted JSON blob
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, check_in_type, check_in_date)
);

alter table public.check_ins enable row level security;

create policy "Users can manage own check_ins"
  on public.check_ins for all using (auth.uid() = user_id);

-- ============================================================
-- journal_entries (encrypted)
-- ============================================================
create table if not exists public.journal_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  encrypted_data text not null, -- client-encrypted JSON blob
  is_favorite boolean not null default false,
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.journal_entries enable row level security;

create policy "Users can manage own journal_entries"
  on public.journal_entries for all using (auth.uid() = user_id);

-- ============================================================
-- step_work (encrypted answers)
-- ============================================================
create table if not exists public.step_work (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  step_number int not null,
  question_number int not null,
  encrypted_answer text, -- client-encrypted
  is_complete boolean not null default false,
  completed_at timestamptz,
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, step_number, question_number)
);

alter table public.step_work enable row level security;

create policy "Users can manage own step_work"
  on public.step_work for all using (auth.uid() = user_id);

-- ============================================================
-- step_progress
-- ============================================================
create table if not exists public.step_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  step_number int not null,
  status text not null default 'not_started',
  completion_percentage double precision not null default 0,
  completed_at timestamptz,
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, step_number)
);

alter table public.step_progress enable row level security;

create policy "Users can manage own step_progress"
  on public.step_progress for all using (auth.uid() = user_id);

-- ============================================================
-- meetings (user-saved meetings)
-- ============================================================
create table if not exists public.meetings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  location text not null,
  address text,
  meeting_date timestamptz,
  meeting_type text not null default 'in-person',
  formats text[] not null default '{}',
  encrypted_notes text, -- client-encrypted
  is_favorite boolean not null default false,
  latitude double precision,
  longitude double precision,
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.meetings enable row level security;

create policy "Users can manage own meetings"
  on public.meetings for all using (auth.uid() = user_id);

-- ============================================================
-- gratitude_entries (encrypted)
-- ============================================================
create table if not exists public.gratitude_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  encrypted_content text not null, -- client-encrypted
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.gratitude_entries enable row level security;

create policy "Users can manage own gratitude_entries"
  on public.gratitude_entries for all using (auth.uid() = user_id);

-- ============================================================
-- safety_plans (encrypted)
-- ============================================================
create table if not exists public.safety_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  encrypted_data text not null, -- client-encrypted JSON blob
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id) -- one safety plan per user
);

alter table public.safety_plans enable row level security;

create policy "Users can manage own safety_plans"
  on public.safety_plans for all using (auth.uid() = user_id);

-- ============================================================
-- contacts (encrypted — sponsor, emergency contacts)
-- ============================================================
create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  encrypted_data text not null, -- client-encrypted JSON blob
  relationship text not null, -- 'sponsor', 'emergency', 'sponsee'
  is_primary boolean not null default false,
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.contacts enable row level security;

create policy "Users can manage own contacts"
  on public.contacts for all using (auth.uid() = user_id);

-- ============================================================
-- challenges (not encrypted — non-sensitive)
-- ============================================================
create table if not exists public.challenges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null,
  duration_days int not null,
  start_date timestamptz not null,
  end_date timestamptz,
  is_completed boolean not null default false,
  is_active boolean not null default true,
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.challenges enable row level security;

create policy "Users can manage own challenges"
  on public.challenges for all using (auth.uid() = user_id);

-- ============================================================
-- achievements (not encrypted — non-sensitive)
-- ============================================================
create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  achievement_key text not null,
  type text not null, -- 'milestone', 'streak', 'step_completion'
  earned_at timestamptz not null default now(),
  is_viewed boolean not null default false,
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, achievement_key)
);

alter table public.achievements enable row level security;

create policy "Users can manage own achievements"
  on public.achievements for all using (auth.uid() = user_id);

-- ============================================================
-- ai_conversations (encrypted)
-- ============================================================
create table if not exists public.ai_conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.ai_conversations enable row level security;

create policy "Users can manage own ai_conversations"
  on public.ai_conversations for all using (auth.uid() = user_id);

-- ============================================================
-- ai_messages (encrypted content)
-- ============================================================
create table if not exists public.ai_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.ai_conversations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  encrypted_content text not null, -- client-encrypted
  is_user boolean not null,
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.ai_messages enable row level security;

create policy "Users can manage own ai_messages"
  on public.ai_messages for all using (auth.uid() = user_id);

-- ============================================================
-- reading_reflections (encrypted)
-- ============================================================
create table if not exists public.reading_reflections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  reading_id text not null,
  reading_date date not null,
  encrypted_reflection text not null, -- client-encrypted
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, reading_id, reading_date)
);

alter table public.reading_reflections enable row level security;

create policy "Users can manage own reading_reflections"
  on public.reading_reflections for all using (auth.uid() = user_id);

-- ============================================================
-- Indexes for sync queries
-- ============================================================
create index idx_check_ins_updated on public.check_ins(user_id, updated_at);
create index idx_journal_entries_updated on public.journal_entries(user_id, updated_at);
create index idx_step_work_updated on public.step_work(user_id, updated_at);
create index idx_gratitude_entries_updated on public.gratitude_entries(user_id, updated_at);
create index idx_achievements_updated on public.achievements(user_id, updated_at);
create index idx_ai_messages_conversation on public.ai_messages(conversation_id, created_at);

-- ============================================================
-- Auto-update updated_at trigger
-- ============================================================
create or replace function public.update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Apply trigger to all tables with updated_at
do $$
declare
  tbl text;
begin
  for tbl in
    select unnest(array[
      'profiles', 'check_ins', 'journal_entries', 'step_work',
      'step_progress', 'meetings', 'gratitude_entries', 'safety_plans',
      'contacts', 'challenges', 'achievements', 'ai_conversations',
      'ai_messages', 'reading_reflections'
    ])
  loop
    execute format(
      'create trigger set_updated_at before update on public.%I
       for each row execute function public.update_updated_at()',
      tbl
    );
  end loop;
end;
$$;

-- ============================================================
-- Profile auto-creation on auth signup
-- ============================================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, created_at, updated_at)
  values (new.id, new.email, now(), now());
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
