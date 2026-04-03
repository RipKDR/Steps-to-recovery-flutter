# Meta Project HUB Skill

**Version:** 1.0.0  
**Status:** Building Now  
**Purpose:** Build and operate the Meta Project HUB - a personalized AI agent orchestration platform for Steps to Recovery Flutter app

---

## What This Skill Does

This skill provides expertise for building a **production-grade AI agent orchestration dashboard** that combines:

1. **Mission Control architecture** (32 panels, WebSocket, SQLite, Next.js 16)
2. **MUTX-DEV operations** (governance, sessions, usage analytics, AARM compliance)
3. **Flutter app integration** (recovery app specific metrics)
4. **Meta-Systems Hub** (17 existing PowerShell scripts)
5. **Self-Evolving Agent** (memory & continuous improvement)

---

## When to Use This Skill

Use this skill when:
- Building the Meta Project HUB dashboard
- Creating AI agent orchestration features
- Integrating Flutter app metrics
- Implementing governance/policy engines
- Building real-time monitoring dashboards
- Creating Kanban boards for task management
- Setting up usage analytics and budget tracking

---

## Architecture Knowledge

### Tech Stack
| Layer | Technology |
|-------|------------|
| **Backend** | FastAPI (Python) |
| **Frontend** | Next.js 16 (App Router) |
| **UI** | React 19 + Tailwind CSS |
| **State** | Zustand 5 |
| **Charts** | Recharts 3 |
| **Database** | SQLite (better-sqlite3, WAL mode) |
| **Real-time** | WebSocket + SSE |
| **Auth** | Session + API Key + RBAC |
| **Monitoring** | OpenTelemetry |

### API Structure (`/v1/*`)
```
/v1/auth          - Authentication
/v1/agents        - Agent management
/v1/sessions      - Session tracking
/v1/usage         - Token/cost analytics
/v1/budgets       - Budget limits
/v1/governance    - Policy engine (Faramesh-inspired)
/v1/flutter       - Flutter app metrics
/v1/meta-systems  - Meta-Systems Hub integration
/v1/tasks         - Kanban board
/v1/memory        - Self-improving memory
/v1/security      - Security audit
/v1/monitoring    - OpenTelemetry
```

### 32 Panels
**Agent Operations (8):**
1. Assistant Overview
2. Session Discovery
3. Channel Inspection
4. Gateway Health
5. Deployment Status
6. Usage Analytics
7. Budgets & Limits
8. Skill Management

**Flutter App (6):**
9. Code Health
10. Test Coverage
11. Build Status
12. Dependencies
13. Performance
14. Feature Tracker

**Meta-Systems (6):**
15. Security Scan
16. Code Smells
17. Auto-Fix Log
18. Git Status
19. CI/CD Status
20. Activity Feed

**Tasks (6):**
21. Kanban Board
22. Sprint Planning
23. Backlog
24. Recovery Roadmap
25. Bug Tracker
26. Feature Requests

**Memory (4):**
27. Semantic Memory
28. Episodic Memory
29. Working Memory
30. Pattern Evolution

**Security (4):**
31. Security Audit
32. PII Detection
33. Encryption Status
34. Recovery Compliance

---

## Implementation Patterns

### Backend Service Pattern
```python
class FlutterService:
    """Service for Flutter app metrics"""
    
    def get_code_health(self):
        """Run flutter analyze and return metrics"""
        # Implementation
        
    def get_test_coverage(self):
        """Parse coverage/lcov.info"""
        # Implementation
        
    def get_build_status(self):
        """Check APK/Web build status"""
        # Implementation
```

### API Route Pattern
```python
from fastapi import APIRouter

router = APIRouter(prefix="/v1/flutter", tags=["Flutter"])

@router.get("/code-health")
async def get_code_health():
    """Get Flutter code health metrics"""
    return {"success": True, "data": {...}}
```

### Frontend Panel Pattern
```tsx
'use client';

import { useStore } from '@/store';
import { LineChart, Line, XAxis, YAxis } from 'recharts';

export function CodeHealthPanel() {
  const { codeHealth, trends } = useStore();
  
  return (
    <Panel title="Code Health" icon="💻">
      <Metric value={codeHealth.score} trend={trends.codeHealth} />
      <LineChart data={trends.codeHealthData}>
        {/* Chart config */}
      </LineChart>
    </Panel>
  );
}
```

### WebSocket Real-time Pattern
```python
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_json()
            # Broadcast to all clients
            await manager.broadcast({
                "type": "metrics_update",
                "data": get_all_metrics()
            })
    except WebSocketDisconnect:
        manager.disconnect(websocket)
```

### Governance Engine Pattern (Faramesh-inspired)
```python
class GovernanceService:
    """Policy engine for agent actions"""
    
    def __init__(self):
        self.policies = load_policies()
    
    def evaluate(self, action: AgentAction) -> PolicyResult:
        """Evaluate if action is permitted"""
        for policy in self.policies:
            if policy.matches(action):
                if not policy.permits(action):
                    return PolicyResult(deny=True, reason=policy.reason)
        return PolicyResult(permit=True)
```

---

## Best Practices

### DO
- ✅ Use `/v1/*` prefix for all API routes
- ✅ Implement WebSocket for real-time updates
- ✅ Store metrics in SQLite with WAL mode
- ✅ Use Zustand for frontend state
- ✅ Create reusable panel components
- ✅ Add OpenTelemetry for observability
- ✅ Implement RBAC (Viewer/Operator/Admin)
- ✅ Add session tracking and budgets
- ✅ Create governance policies for agent actions

### DON'T
- ❌ Use generic AI aesthetics (Inter font, purple gradients)
- ❌ Skip accessibility (WCAG AA required)
- ❌ Forget loading/empty/error states
- ❌ Hardcode values (use config/env vars)
- ❌ Ignore performance (aim for <100ms updates)
- ❌ Skip security (PII detection, encryption audit)

---

## Design Direction

**Theme:** "Recovery Tech" - Dark, professional, hopeful

| Element | Value |
|---------|-------|
| **Background** | True black (#0A0A0A) |
| **Primary** | Amber (#F59E0B) - recovery/hope |
| **Accent** | Cyan/Teal gradients - tech |
| **Display Font** | Space Grotesk |
| **Body Font** | Inter |
| **Motion** | Staggered reveals, smooth transitions |
| **Layout** | Asymmetric grid, overlapping |
| **Details** | Gradient meshes, noise textures |

---

## File Structure

```
meta-project-hub/
├── backend/
│   ├── main.py
│   ├── api/
│   │   └── routes/
│   ├── services/
│   └── database/
├── frontend/
│   ├── src/
│   │   ├── app/
│   │   ├── components/
│   │   ├── lib/
│   │   └── store/
│   └── package.json
└── integration/
    ├── meta-systems/
    ├── self-improving/
    └── flutter-app/
```

---

## Quick Start Commands

```bash
# Backend
cd meta-project-hub/backend
python main.py

# Frontend
cd meta-project-hub/frontend
npm run dev

# Install dependencies
pip install fastapi uvicorn better-sqlite3
npm install next react tailwind zustand recharts
```

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Panels | 32 functional |
| API Endpoints | 101 total |
| Real-time Latency | <100ms |
| Accessibility | WCAG AA |
| Performance | Lighthouse 90+ |
| Security | 0 PII leaks |

---

## References

- **Mission Control:** https://github.com/builderz-labs/mission-control
- **MUTX-DEV:** https://github.com/mutx-dev/mutx-dev
- **FastAPI:** https://fastapi.tiangolo.com/
- **Next.js 16:** https://nextjs.org/
- **Zustand:** https://zustand-demo.pmnd.rs/
- **Recharts:** https://recharts.org/

---

**Created:** 2026-04-02  
**Version:** 1.0.0  
**Status:** Active Development
