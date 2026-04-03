# 🚀 Meta Project HUB - Tailored for Steps to Recovery Flutter

**A personalized AI agent orchestration platform specifically designed for managing the Steps to Recovery Flutter app development.**

---

## 🎯 **What This Is**

A **Next.js 16 + FastAPI hybrid dashboard** that combines:
- ✅ **Mission Control's architecture** (32 panels, WebSocket, SQLite, RBAC)
- ✅ **Flutter app integration** (recovery app specific metrics)
- ✅ **Meta-Systems Hub** (your existing 17 scripts)
- ✅ **Self-improving agent** (learns from every session)
- ✅ **AI agent orchestration** (manage your Qwen agents)

---

## 🏗️ **Architecture**

```
meta-project-hub/
├── backend/                      # FastAPI + Python
│   ├── main.py                   # Main server
│   ├── api/
│   │   ├── routes/
│   │   │   ├── dashboard.py      # Overview dashboard
│   │   │   ├── flutter/          # Flutter app metrics
│   │   │   │   ├── code_health.py
│   │   │   │   ├── test_coverage.py
│   │   │   │   └── build_status.py
│   │   │   ├── agents/           # Qwen agent management
│   │   │   │   ├── skills.py
│   │   │   │   ├── sessions.py
│   │   │   │   └── orchestrator.py
│   │   │   ├── meta-systems/     # Your 17 scripts
│   │   │   │   ├── scans.py
│   │   │   │   ├── security.py
│   │   │   │   └── code-health.py
│   │   │   ├── tasks/            # Kanban board
│   │   │   ├── memory/           # Self-improving memory
│   │   │   └── security/         # Security audit
│   │   └── models/
│   ├── services/
│   │   ├── flutter_service.py    # Flutter app integration
│   │   ├── agent_service.py      # Qwen agent orchestration
│   │   └── memory_service.py     # Self-improving memory
│   └── database/
│       └── db.sqlite             # SQLite (WAL mode)
│
├── frontend/                     # Next.js 16
│   ├── src/
│   │   ├── app/
│   │   │   ├── page.tsx          # SPA shell
│   │   │   ├── dashboard/        # Overview
│   │   │   ├── flutter/          # Flutter metrics
│   │   │   ├── agents/           # Agent management
│   │   │   ├── tasks/            # Kanban board
│   │   │   ├── memory/           # Knowledge graph
│   │   │   └── security/         # Security audit
│   │   ├── components/
│   │   │   ├── layout/
│   │   │   │   ├── NavRail.tsx   # Primary nav
│   │   │   │   ├── HeaderBar.tsx # Top bar
│   │   │   │   └── LiveFeed.tsx  # Activity stream
│   │   │   ├── panels/           # 32 feature panels
│   │   │   └── charts/           # Recharts visualizations
│   │   ├── lib/
│   │   │   ├── db.ts             # SQLite (better-sqlite3)
│   │   │   ├── websocket.ts      # Real-time updates
│   │   │   └── auth.ts           # RBAC
│   │   └── store/
│   │       └── index.ts          # Zustand state
│   └── package.json
│
└── integration/
    ├── meta-systems/             # Your existing 17 scripts
    ├── self-improving/           # Memory & learnings
    └── flutter-app/              # Recovery app integration
```

---

## 📊 **32 Personalized Panels**

### **Flutter App Metrics (6 panels)**
1. **Code Health** - `flutter analyze` results, trends
2. **Test Coverage** - Coverage %, untested files, auto-generate
3. **Build Status** - APK/Web build status, errors
4. **Dependencies** - pub.dev updates, vulnerabilities
5. **Performance** - App size, load times, jank detection
6. **Recovery Features** - Feature completion tracker

### **AI Agent Orchestration (6 panels)**
7. **Agent Status** - Qwen agents online/offline, heartbeats
8. **Skill Management** - Install/update skills from ClawdHub
9. **Session Tracking** - Active agent sessions, token usage
10. **Task Queue** - Agent task assignments, progress
11. **Memory Graph** - Self-improving memory visualization
12. **Eval Results** - Agent performance metrics

### **Meta-Systems Hub (6 panels)**
13. **Security Scan** - PII detection, encryption audit
14. **Code Smells** - Long methods, god classes
15. **Auto-Fix Log** - Recent auto-fixes, rollbacks
16. **Git Status** - Branch, commits, push/pull
17. **CI/CD Status** - GitHub Actions results
18. **Activity Feed** - Real-time event stream

### **Task Management (6 panels)**
19. **Kanban Board** - Inbox → Assigned → In Progress → Review → Quality → Done
20. **Sprint Planning** - Current sprint, story points
21. **Backlog** - Prioritized feature backlog
22. **Recovery Roadmap** - App release timeline
23. **Bug Tracker** - Reported bugs, fixes
24. **Feature Requests** - User requests, voting

### **Memory & Learning (4 panels)**
25. **Semantic Memory** - Reusable patterns (0.95+ confidence)
26. **Episodic Memory** - Session experiences
27. **Working Memory** - Current session context
28. **Pattern Evolution** - Pattern updates, corrections

### **Security & Compliance (4 panels)**
29. **Security Audit** - Trust score (0-100), issues
30. **PII Detection** - Leaks found, fixed
31. **Encryption Status** - AES-256 validation
32. **Compliance** - Recovery app compliance checklist

---

## 🔌 **API Endpoints (101 total)**

### **Flutter App APIs**
```
GET  /api/flutter/analyze          # Run flutter analyze
GET  /api/flutter/test-coverage    # Coverage report
GET  /api/flutter/build-status     # Build status
GET  /api/flutter/dependencies     # Dependency updates
POST /api/flutter/build-apk        # Trigger APK build
POST /api/flutter/generate-tests   # Auto-generate tests
```

### **Agent Orchestration APIs**
```
GET  /api/agents/status           # Agent heartbeats
POST /api/agents/spawn            # Spawn sub-agent
POST /api/agents/skill-add        # Install skill
GET  /api/agents/sessions         # Active sessions
GET  /api/agents/tokens           # Token usage
POST /api/agents/eval             # Run agent eval
```

### **Meta-Systems APIs**
```
POST /api/meta/scan-all           # Run all scans
GET  /api/meta/security-report    # Security audit
GET  /api/meta/code-smells        # Code smell report
POST /api/meta/auto-fix           # Auto-fix issues
GET  /api/meta/git-status         # Git status
POST /api/meta/commit             # Commit changes
```

### **Task Management APIs**
```
GET  /api/tasks/kanban            # Kanban board
POST /api/tasks/create            # Create task
PUT  /api/tasks/move              # Move task (drag-drop)
GET  /api/tasks/sprint            # Current sprint
POST /api/tasks/sprint-start      # Start sprint
```

### **Memory APIs**
```
GET  /api/memory/semantic         # Semantic patterns
POST /api/memory/episodic         # Store experience
GET  /api/memory/working          # Working memory
POST /api/memory/consolidate      # Consolidate memory
```

---

## 🎨 **UI Layout**

```
┌─────────────────────────────────────────────────────────────────┐
│  [Logo] Meta Project HUB              [Search]  [🔔] [⚙] [👤]  │
│  HeaderBar - Global controls, status indicators                │
├──────┬──────────────────────────────────────────────────────────┤
│      │                                                          │
│ Nav  │  ┌──────────────────────────────────────────────────┐   │
│ Rail │  │  Overview Dashboard                              │   │
│      │  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐    │   │
│ 📊   │  │  │Flutter │ │ Agents │ │ Tasks  │ │Security│    │   │
│ 💻   │  │  │ 100%   │ │ 8 onln │ │ 12 act │ │ 92/100 │    │   │
│ 🔒   │  │  └────────┘ └────────┘ └────────┘ └────────┘    │   │
│ 🧪   │  │                                                  │   │
│ 📦   │  │  ┌──────────────────┐ ┌──────────────────────┐   │   │
│ ✅   │  │  │  Kanban Board    │ │  Live Activity Feed  │   │   │
│ 🧠   │  │  │  [12 active]     │ │  • Agent completed   │   │   │
│ 🔐   │  │  │  → → → → → Done  │ │  • Test gen: +5%     │   │   │
│      │  │  └──────────────────┘ └──────────────────────┘   │   │
│      │  └──────────────────────────────────────────────────┘   │
│      │                                                          │
└──────┴──────────────────────────────────────────────────────────┘
```

---

## 🛠️ **Tech Stack**

| Layer | Technology | Why |
|-------|------------|-----|
| **Frontend** | Next.js 16 | App Router, SSR, API routes |
| **UI** | React 19 + Tailwind | Component library |
| **State** | Zustand 5 | Lightweight, fast |
| **Charts** | Recharts 3 | Beautiful visualizations |
| **Backend** | FastAPI | Python, async, easy Flutter integration |
| **Database** | SQLite (better-sqlite3) | Zero-config, WAL mode |
| **Real-time** | WebSocket + SSE | Live updates |
| **Auth** | Session + API Key | RBAC (Viewer/Operator/Admin) |
| **Validation** | Zod 4 | Type-safe schemas |

---

## 🚀 **Quick Start**

### **1. Install Dependencies**
```bash
# Frontend
cd frontend
npm install

# Backend
cd backend
pip install -r requirements.txt
```

### **2. Start Backend**
```bash
cd backend
python main.py
# Runs on http://localhost:5000
```

### **3. Start Frontend**
```bash
cd frontend
npm run dev
# Runs on http://localhost:3000
```

### **4. Open Dashboard**
```
http://localhost:3000
```

---

## 🎯 **Flutter App Integration**

### **Code Health Monitoring**
```python
# Automatically runs flutter analyze
# Tracks errors/warnings over time
# Auto-fixes safe issues
```

### **Test Coverage**
```python
# Parses coverage/lcov.info
# Identifies untested files
# Auto-generates tests
```

### **Build Status**
```python
# Monitors APK/Web builds
# Reports build errors
# Tracks build times
```

### **Dependency Updates**
```python
# Checks pub.dev for updates
# Alerts on vulnerabilities
# Auto-updates safe packages
```

---

## 🧠 **Self-Improving Integration**

### **Memory Storage**
```
memory/
├── semantic/         # Reusable patterns
│   └── patterns.json
├── episodic/         # Session experiences
│   └── YYYY-MM-DD-{session}.json
├── working/          # Current session
│   └── current.json
└── corrections/      # Skill corrections
    └── corrections.md
```

### **Pattern Extraction**
```python
# After each session:
1. Extract experience
2. Abstract to pattern
3. Store in semantic memory
4. Update confidence score
5. Apply to future sessions
```

---

## 🔐 **Security Features**

### **Recovery App Specific**
- ✅ **PII Detection** - Scan for phone/email/password in logs
- ✅ **Encryption Audit** - Validate AES-256 implementation
- ✅ **Secure Storage** - Check flutter_secure_storage usage
- ✅ **Compliance** - Recovery app compliance checklist

### **Platform Security**
- ✅ **RBAC** - Viewer/Operator/Admin roles
- ✅ **API Key Auth** - Headless access
- ✅ **CORS** - Localhost only
- ✅ **CSRF Protection** - Token validation

---

## 📊 **Metrics Tracked**

### **Flutter App**
- Code health score (0-100)
- Test coverage %
- Build success rate
- Dependency freshness
- Feature completion %

### **AI Agents**
- Sessions completed
- Token usage
- Success rate
- Pattern confidence
- Memory growth

### **Meta-Systems**
- Security score (0-100)
- Auto-fix success rate
- Code smells fixed
- Git activity
- CI/CD pass rate

---

## 🎓 **Learnings from Mission Control**

### **Applied Patterns**
1. **32 Panels** - Comprehensive coverage
2. **Kanban Board** - 6 columns for task flow
3. **Live Feed** - Real-time activity stream
4. **Memory Graph** - Visualize knowledge
5. **Security Trust Score** - 0-100 scoring
6. **Agent Evals** - Four-layer evaluation
7. **Skill Sync** - Disk ↔ DB sync
8. **Natural Language Cron** - "every morning at 9am"

### **Personalized for Flutter**
1. **Flutter-specific panels** - Code health, tests, builds
2. **Recovery app metrics** - Feature tracker, compliance
3. **Meta-systems integration** - Your 17 existing scripts
4. **Self-improving** - Learns from every session

---

## 📁 **File Structure**

See `ARCHITECTURE.md` for complete file-by-file breakdown.

---

## 🎯 **Success Criteria**

| Criterion | Target | Status |
|-----------|--------|--------|
| **32 Panels** | All implemented | ⏳ In Progress |
| **101 APIs** | All endpoints | ⏳ In Progress |
| **Real-time** | WebSocket + SSE | ⏳ In Progress |
| **SQLite** | WAL mode, migrations | ⏳ In Progress |
| **Auth** | RBAC, session, API key | ⏳ In Progress |
| **Flutter Integration** | Code health, tests, builds | ⏳ In Progress |
| **Meta-Systems** | 17 scripts integrated | ⏳ In Progress |
| **Self-Improving** | Memory, patterns, learnings | ⏳ In Progress |

---

**Version:** 2.0.0 (Meta Personalized)  
**Created:** 2026-04-02  
**Based On:** Mission Control v2.0.1 + Flutter App Needs + Meta-Systems Hub  
**Status:** 🚀 Building Now
