# Meta Project HUB

**AI Agent Orchestration Platform for Steps to Recovery Flutter App**

A production-grade dashboard combining:
- **Mission Control** architecture (32 panels, WebSocket, SQLite)
- **MUTX-DEV** operations (governance, sessions, usage analytics)
- **Flutter app** integration (code health, tests, builds)
- **Meta-Systems Hub** (17 PowerShell scripts)
- **Self-Evolving Agent** (continuous improvement)

---

## 🚀 Quick Start

### Backend

```bash
cd meta-project-hub/backend
pip install -r requirements.txt
python main.py
```

Access at: http://localhost:8000

### Frontend (Coming Soon)

```bash
cd meta-project-hub/frontend
npm install
npm run dev
```

Access at: http://localhost:3000

---

## 📊 Features

### 32 Panels
- **8 Agent Operations** - Status, sessions, usage, governance
- **6 Flutter Metrics** - Code health, tests, builds, dependencies
- **6 Meta-Systems** - Security, code smells, auto-fix, CI/CD
- **6 Task Management** - Kanban, sprint, backlog, roadmap
- **4 Memory** - Semantic, episodic, working, evolution
- **4 Security** - Audit, PII, encryption, compliance

### 101 API Endpoints
All routes under `/v1/*`:
- `/v1/auth` - Authentication, API keys, RBAC
- `/v1/agents` - Agent management
- `/v1/sessions` - Session tracking
- `/v1/usage` - Token/cost analytics
- `/v1/budgets` - Budget limits
- `/v1/governance` - Policy engine
- `/v1/flutter` - Flutter metrics
- `/v1/meta-systems` - Meta-Systems integration
- `/v1/tasks` - Kanban board
- `/v1/memory` - Self-improving memory
- `/v1/security` - Security audit
- `/v1/monitoring` - OpenTelemetry

### Real-time Updates
- WebSocket connection (`/ws`)
- 10-second broadcast interval
- Channel subscriptions
- Manual refresh support

---

## 🏗️ Architecture

```
meta-project-hub/
├── backend/
│   ├── main.py                  # FastAPI app
│   ├── api/routes/              # 12 route modules
│   ├── services/                # WebSocket, Memory, Usage
│   └── database/                # SQLite
├── frontend/                    # Next.js 16 (coming)
│   └── src/
└── integration/                 # Meta-Systems, Flutter
```

---

## 📖 Documentation

- [Full Spec](../META_PROJECT_HUB_SPEC.md)
- [API Docs](http://localhost:8000/docs)
- [Mission Control Reference](https://github.com/builderz-labs/mission-control)
- [MUTX-DEV Reference](https://github.com/mutx-dev/mutx-dev)

---

**Version:** 1.0.0  
**Status:** Backend Complete ✅  
**Frontend:** In Progress ⏳
