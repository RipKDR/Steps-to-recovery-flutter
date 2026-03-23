-- SQLBook: Code
-- ============================================================
-- Extensions
-- ============================================================
create extension if not exists pgcrypto;
-- ============================================================
-- Utility function: updated_at
-- ============================================================
create or replace function public.update_updated_at() returns trigger language plpgsql as $$ begin new.updated_at = now();
return new;
end;
$$;
-- ============================================================
-- profiles
-- ============================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  program_type text check (
    program_type in ('aa', 'na', 'ca', 'other')
    or program_type is null
  ),
  sobriety_start_date date,
  display_name text,
  device_id text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
drop policy if exists "Users can view own profile" on public.profiles;
drop policy if exists "Users can insert own profile" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
drop policy if exists "Users can delete own profile" on public.profiles;
create policy "profiles_select_own" on public.profiles for
select using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles for
insert with check (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for
update using (auth.uid() = id) with check (auth.uid() = id);
create policy "profiles_delete_own" on public.profiles for delete using (auth.uid() = id);
-- ============================================================
-- check_ins
-- ============================================================
create table if not exists public.check_ins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  check_in_type text not null check (check_in_type in ('morning', 'evening')),
  check_in_date date not null,
  encrypted_data text not null,
  encryption_version smallint not null default 1,
  key_id text,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, check_in_type, check_in_date)
);
alter table public.check_ins enable row level security;
drop policy if exists "Users can manage own check_ins" on public.check_ins;
create policy "check_ins_select_own" on public.check_ins for
select using (auth.uid() = user_id);
create policy "check_ins_insert_own" on public.check_ins for
insert with check (auth.uid() = user_id);
create policy "check_ins_update_own" on public.check_ins for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "check_ins_delete_own" on public.check_ins for delete using (auth.uid() = user_id);
create index if not exists idx_check_ins_user_updated on public.check_ins (user_id, updated_at desc);
create index if not exists idx_check_ins_user_date on public.check_ins (user_id, check_in_date desc);
-- ============================================================
-- step_progress
-- ============================================================
create table if not exists public.step_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  step_number int not null check (
    step_number between 1 and 12
  ),
  status text not null default 'not_started' check (
    status in ('not_started', 'in_progress', 'completed')
  ),
  completion_percentage double precision not null default 0 check (
    completion_percentage >= 0
    and completion_percentage <= 100
  ),
  completed_at timestamptz,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, step_number)
);
alter table public.step_progress enable row level security;
drop policy if exists "Users can manage own step_progress" on public.step_progress;
create policy "step_progress_select_own" on public.step_progress for
select using (auth.uid() = user_id);
create policy "step_progress_insert_own" on public.step_progress for
insert with check (auth.uid() = user_id);
create policy "step_progress_update_own" on public.step_progress for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "step_progress_delete_own" on public.step_progress for delete using (auth.uid() = user_id);
-- ============================================================
-- step_work
-- ============================================================
create table if not exists public.step_work (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  step_number int not null check (
    step_number between 1 and 12
  ),
  question_number int not null check (question_number > 0),
  encrypted_answer text,
  encryption_version smallint not null default 1,
  key_id text,
  is_complete boolean not null default false,
  completed_at timestamptz,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, step_number, question_number)
);
alter table public.step_work enable row level security;
drop policy if exists "Users can manage own step_work" on public.step_work;
create policy "step_work_select_own" on public.step_work for
select using (auth.uid() = user_id);
create policy "step_work_insert_own" on public.step_work for
insert with check (auth.uid() = user_id);
create policy "step_work_update_own" on public.step_work for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "step_work_delete_own" on public.step_work for delete using (auth.uid() = user_id);
-- ============================================================
-- ai_conversations / ai_messages
-- ============================================================
create table if not exists public.ai_conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
alter table public.ai_conversations enable row level security;
drop policy if exists "Users can manage own ai_conversations" on public.ai_conversations;
create policy "ai_conversations_select_own" on public.ai_conversations for
select using (auth.uid() = user_id);
create policy "ai_conversations_insert_own" on public.ai_conversations for
insert with check (auth.uid() = user_id);
create policy "ai_conversations_update_own" on public.ai_conversations for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "ai_conversations_delete_own" on public.ai_conversations for delete using (auth.uid() = user_id);
create table if not exists public.ai_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.ai_conversations(id) on delete cascade,
  encrypted_content text not null,
  encryption_version smallint not null default 1,
  key_id text,
  is_user boolean not null,
  device_id text,
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
alter table public.ai_messages enable row level security;
drop policy if exists "Users can manage own ai_messages" on public.ai_messages;
create policy "ai_messages_select_own" on public.ai_messages for
select using (
    exists (
      select 1
      from public.ai_conversations c
      where c.id = ai_messages.conversation_id
        and c.user_id = auth.uid()
    )
  );
create policy "ai_messages_insert_own" on public.ai_messages for
insert with check (
    exists (
      select 1
      from public.ai_conversations c
      where c.id = ai_messages.conversation_id
        and c.user_id = auth.uid()
    )
  );
create policy "ai_messages_update_own" on public.ai_messages for
update using (
    exists (
      select 1
      from public.ai_conversations c
      where c.id = ai_messages.conversation_id
        and c.user_id = auth.uid()
    )
  ) with check (
    exists (
      select 1
      from public.ai_conversations c
      where c.id = ai_messages.conversation_id
        and c.user_id = auth.uid()
    )
  );
create policy "ai_messages_delete_own" on public.ai_messages for delete using (
  exists (
    select 1
    from public.ai_conversations c
    where c.id = ai_messages.conversation_id
      and c.user_id = auth.uid()
  )
);
create index if not exists idx_ai_messages_conversation_created on public.ai_messages (conversation_id, created_at asc);
-- ============================================================
-- updated_at triggers (idempotent)
-- ============================================================
do $$
declare tbl text;
begin foreach tbl in array array [
    'profiles',
    'check_ins',
    'step_progress',
    'step_work',
    'ai_conversations',
    'ai_messages'
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
-- auth signup hook
-- ============================================================
create or replace function public.handle_new_user() returns trigger language plpgsql security definer
set search_path = public as $$ begin
insert into public.profiles (id, email, created_at, updated_at)
values (new.id, new.email, now(), now()) on conflict (id) do nothing;
return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after
insert on auth.users for each row execute function public.handle_new_user();
-- SQLBook: Code

-- SQLBook: Code
