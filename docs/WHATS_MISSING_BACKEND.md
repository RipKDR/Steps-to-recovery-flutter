# Backend/Supabase - What's Missing

> **Assessment Date:** 2026-03-27  
> **Scope:** Supabase backend, database schema, edge functions, storage, CI/CD, and deployment infrastructure

---

## 🚨 Critical Backend Gaps

### 1. Missing Database Tables (Migration Incomplete)

The `sync_service.dart` tries to sync with these tables, but they **DO NOT EXIST** in `supabase/migrations/20260322000001_initial_schema.sql`:

| Table | Referenced In | Status |
|-------|---------------|--------|
| `journal_entries` | `sync_service.dart:221` | ❌ MISSING |
| `gratitude_entries` | `sync_service.dart:358` | ❌ MISSING |
| `achievements` | `sync_service.dart:376` | ❌ MISSING |
| `contacts` | `sync_service.dart:405` | ❌ MISSING |
| `meetings` | `sync_service.dart:425` | ❌ MISSING |
| `safety_plans` | `sync_service.dart:462` | ❌ MISSING |
| `challenges` | `sync_service.dart:482` | ❌ MISSING |
| `reading_reflections` | `sync_service.dart:537` | ❌ MISSING |

**Existing Tables (✅):**
- `profiles` - User profiles
- `check_ins` - Morning/evening check-ins
- `step_progress` - Step completion tracking
- `step_work` - Step answers/work
- `ai_conversations` - AI chat conversations
- `ai_messages` - AI chat messages

**Impact:** Sync will fail for any data related to missing tables. Only 6 out of 14 tables exist.

---

### 2. Storage Buckets Not Configured

**Location:** `supabase/config.toml:114-119`

**Current State:**
```toml
# [storage.buckets.images]
# public = false
# file_size_limit = "50MiB"
# allowed_mime_types = ["image/png", "image/jpeg"]
# objects_path = "./images"
```

**Missing Buckets:**
| Bucket | Purpose | Needed For |
|--------|---------|------------|
| `voice-recordings` | Store journal voice memos | Journal voice feature |
| `user-avatars` | Profile pictures | User profiles |
| `milestones` | Milestone share images | Share functionality |
| `attachments` | General file attachments | Future features |

**Impact:** Voice recording feature cannot store files. No file upload capability.

---

### 3. Seed Data File Missing

**Location:** `supabase/config.toml:65`

**Configuration:**
```toml
[db.seed]
enabled = true
sql_paths = ["./seed.sql"]
```

**Problem:** `supabase/seed.sql` does not exist.

**Needed Seed Data:**
- Default meetings (AA/NA locations)
- Challenge templates
- Sample readings
- Crisis resources
- Test user accounts

**Impact:** Developers must create data manually for testing.

---

## ⚠️ Major Backend Gaps

### 4. Password Reset Not Implemented

**Location:** `lib/features/auth/screens/login_screen.dart:117-124`

**Current State:** Forgot password button exists but is commented out:
```dart
// Forgot password
// TextButton(
//   onPressed: () {}, // TODO: Implement forgot password
//   child: const Text('Forgot Password?'),
// ),
```

**What Needs to Be Done:**
1. Create `ForgotPasswordScreen`
2. Call `Supabase.instance.client.auth.resetPasswordForEmail()`
3. Handle deep link for password reset
4. Update `app_constants.dart:181` route `/forgot-password`

**Supabase Config:** Already enabled in `config.toml:209`

---

### 5. Edge Functions - Limited

**Current Functions:**
| Function | File | Status |
|----------|------|--------|
| `chat` | `supabase/functions/chat/index.ts` | ✅ Implemented |

**Missing Functions:**
| Function | Purpose |
|----------|---------|
| `sync-bulk` | Bulk sync for large datasets |
| `export-data` | GDPR data export |
| `delete-account` | Account deletion with cleanup |
| `webhook-handler` | External service webhooks |
| `password-reset-handler` | Custom password reset flow |

---

### 6. Database Indexes Missing

**Current Indexes (in migration):**
- `idx_check_ins_user_updated` on check_ins
- `idx_check_ins_user_date` on check_ins
- `idx_ai_messages_conversation_created` on ai_messages

**Missing Indexes (should add when creating tables):**
```sql
-- For journal entries
CREATE INDEX idx_journal_entries_user_updated ON journal_entries (user_id, updated_at DESC);
CREATE INDEX idx_journal_entries_user_favorite ON journal_entries (user_id, is_favorite) WHERE is_favorite = true;

-- For meetings
CREATE INDEX idx_meetings_user_favorite ON meetings (user_id, is_favorite) WHERE is_favorite = true;
CREATE INDEX idx_meetings_location ON meetings USING GIST (ll_to_earth(latitude, longitude));

-- For achievements
CREATE INDEX idx_achievements_user_earned ON achievements (user_id, earned_at DESC);

-- For gratitude entries
CREATE INDEX idx_gratitude_entries_user_created ON gratitude_entries (user_id, created_at DESC);

-- For contacts
CREATE INDEX idx_contacts_user_relationship ON contacts (user_id, relationship);
```

---

### 7. No Database Triggers for Missing Tables

**Current Triggers:** Only `set_updated_at` for existing tables.

**Missing Triggers:**
- Auto-update streak calculation for gratitude
- Auto-create achievements on milestones
- Auto-archive old data
- Cascade deletes for related records

---

## 🔧 Configuration Issues

### 8. App Constants - Placeholder Values

**Location:** `lib/core/constants/app_constants.dart:116`

```dart
static const String appStoreUrl = 'https://apps.apple.com/app/steps-to-recovery/idXXXXXXXXX';
```

**Missing:**
- Real App Store ID (replace `XXXXXXXXX`)
- Play Store URL needs verification

---

### 9. CORS Configuration for Edge Functions

**Current State:** `chat` function has CORS headers hardcoded.

**Issue:** May need global CORS config if adding more functions.

---

### 10. Rate Limiting - Not Optimized

**Location:** `supabase/config.toml:180-194`

**Current Settings:**
```toml
[auth.rate_limit]
email_sent = 2  # VERY RESTRICTIVE
sms_sent = 30
anonymous_users = 30
token_refresh = 150
sign_in_sign_ups = 30
token_verifications = 30
web3 = 30
```

**Potential Issues:**
- `email_sent = 2` may be too restrictive for password reset + confirmation
- No custom rate limiting for AI chat endpoint
- No rate limiting on sync endpoints

**Recommendation:**
```toml
email_sent = 10  # Allow for signup + reset + resend
```

---

## 📊 Sync Service Issues

### 11. Bidirectional Sync Gaps

**Current Behavior:**
- ✅ Push: All tables push pending changes
- ✅ Pull: Gets remote changes since last sync

**Issues:**
1. **No conflict resolution** - Simple last-write-wins, may lose data
2. **No batching** - Individual upserts for each record (inefficient)
3. **No retry logic** - Failed syncs don't queue for retry
4. **No sync priority** - Critical data (safety plans) not synced first
5. **No offline queue** - Changes made offline may not sync properly

---

### 12. Missing Sync Status Handling (BUG)

**In `sync_service.dart`:**

These tables push ALL entries (not just pending):
- `gratitude_entries` (line 356) - pushes all
- `contacts` (line 397) - pushes all
- `meetings` (line 425) - pushes all
- `safety_plans` (line 451) - pushes all
- `challenges` (line 480) - pushes all
- `reading_reflections` (line 535) - pushes all

**Correct Implementation (see check_ins for reference):**
```dart
final pending = localCheckIns.where((c) => c.syncStatus == SyncStatus.pending);
```

**Impact:** Unnecessary API calls, wasted bandwidth, potential overwrites.

---

## 🔐 Security & Privacy Gaps

### 13. Row Level Security - Missing for Future Tables

When creating missing tables, must add RLS policies:

```sql
-- Template for new tables
ALTER TABLE public.table_name ENABLE ROW LEVEL SECURITY;

CREATE POLICY "table_select_own" ON public.table_name
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "table_insert_own" ON public.table_name
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "table_update_own" ON public.table_name
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "table_delete_own" ON public.table_name
  FOR DELETE USING (auth.uid() = user_id);
```

---

### 14. Encryption Key Management

**Current:** Single encryption key per user, stored in secure storage.

**Missing:**
- Key rotation strategy
- Per-table key IDs (column exists but not used consistently)
- Backup/recovery mechanism for lost keys
- Key versioning for encrypted data

---

## 🚀 CI/CD & Deployment Gaps

### 15. Missing Deployment Workflows

**Current Workflows:**
| Workflow | File | Purpose |
|----------|------|---------|
| CI | `.github/workflows/ci.yml` | Build APK on push to main |
| PR Check | `.github/workflows/pr_check.yml` | Analyze & test on PR |

**Missing Workflows:**
| Workflow | Purpose |
|----------|---------|
| Deploy Edge Functions | Deploy Supabase functions on merge |
| Database Migrations | Run migrations on staging/production |
| iOS Build & Deploy | Build and deploy to App Store |
| Web Deploy | Deploy to hosting (Firebase/Vercel) |
| Release | Create GitHub release with artifacts |

---

### 16. No Environment Management

**Missing:**
- `.env.example` file for required environment variables
- Staging environment configuration
- Production environment configuration
- Environment validation script

**Required Environment Variables (not documented):**
```bash
SUPABASE_URL=
SUPABASE_ANON_KEY=
GOOGLE_AI_API_KEY=
SENTRY_DSN=
```

---

### 17. No Automated Testing for Backend

**Missing:**
- Integration tests for sync service
- Edge function unit tests
- Database migration tests
- Load testing for sync endpoints

---

## 🧪 Testing & Development Gaps

### 18. No Local Development Seed Data

**Missing:** `supabase/seed.sql` with:
- Test user accounts (test@example.com / password)
- Sample check-ins for past 30 days
- Sample journal entries
- Test meetings (local AA/NA chapters)
- Sample AI conversations

**Impact:** Developers must create data manually for testing.

---

### 19. Edge Function Testing

**Missing:** Test suite for `chat` edge function.

**Needed:**
- Unit tests for prompt formatting
- Mock tests for API calls
- Rate limiting tests
- Error handling tests

---

## 📱 Push Notifications

### 20. Push Notifications Not Configured

**Current:** Only local notifications via `flutter_local_notifications`.

**Missing:**
- Firebase Cloud Messaging (FCM) setup
- Apple Push Notification Service (APNs) certificates
- Push notification handling in app
- Server-side push triggers (Supabase hooks)

**Use Cases:**
- Milestone reminders
- Sponsor messages
- Crisis check-ins
- Meeting reminders

---

## 📋 Migration Checklist

To fix all backend gaps, create this migration file:

```sql
-- 20260328000001_add_missing_tables.sql

-- 1. journal_entries
-- 2. gratitude_entries
-- 3. achievements
-- 4. contacts
-- 5. meetings
-- 6. safety_plans
-- 7. challenges
-- 8. reading_reflections
-- 9. Add indexes
-- 10. Add RLS policies
-- 11. Add triggers
```

---

## 🎯 Priority Recommendations

### Phase 1: Critical (Fix Immediately)
1. **Create missing database tables** - Sync is broken without these
2. **Add RLS policies** - Security risk
3. **Fix sync to only push pending** - Data efficiency bug

### Phase 2: High Priority (1 week)
4. **Implement password reset** - Auth completeness
5. **Create seed.sql** - Developer experience
6. **Add storage buckets** - Voice recordings
7. **Add deployment workflow for edge functions**

### Phase 3: Medium Priority (2-4 weeks)
8. **Add database indexes** - Performance
9. **Implement conflict resolution** - Data integrity
10. **Add more edge functions** - Features
11. **Setup push notifications**

### Phase 4: Low Priority (Ongoing)
12. **Rate limiting optimization**
13. **Key rotation system**
14. **Backup/recovery**
15. **Load testing**

---

## 📁 Related Files

### Configuration:
- `supabase/migrations/20260322000001_initial_schema.sql` - Current schema
- `supabase/config.toml` - Supabase configuration
- `supabase/.gitignore` - Secrets exclusion
- `lib/app_config.dart` - Environment configuration

### Functions:
- `supabase/functions/chat/index.ts` - AI chat function

### Services:
- `lib/core/services/sync_service.dart` - Sync logic
- `lib/core/services/database_service.dart` - Local database
- `lib/core/services/encryption_service.dart` - Encryption
- `lib/core/services/ai_service.dart` - AI integration

### CI/CD:
- `.github/workflows/ci.yml` - Main CI
- `.github/workflows/pr_check.yml` - PR checks

### Documentation:
- `docs/WHATS_MISSING.md` - Frontend gaps
- `AGENTS.md` - Architecture overview
