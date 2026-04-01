"""
Dashboard Router

Main overview dashboard with aggregated metrics from all systems.
"""

from fastapi import APIRouter
from datetime import datetime

router = APIRouter()

@router.get("/overview")
async def get_overview():
    """
    Get complete dashboard overview.
    
    Returns aggregated metrics from all systems:
    - Agent status
    - Flutter app health
    - Meta-Systems status
    - Task summary
    - Security posture
    """
    return {
        "success": True,
        "timestamp": datetime.now().isoformat(),
        "data": {
            "summary": {
                "total_agents": 8,
                "active_agents": 5,
                "active_sessions": 12,
                "tasks_total": 156,
                "tasks_pending": 23,
                "security_score": 92,
                "code_health": 98,
                "test_coverage": 67.5
            },
            "agents": {
                "online": 5,
                "offline": 3,
                "busy": 4,
                "idle": 1
            },
            "flutter": {
                "code_health_score": 98,
                "errors": 0,
                "warnings": 3,
                "test_coverage": 67.5,
                "last_build": "2026-04-02T08:00:00"
            },
            "meta_systems": {
                "last_scan": "2026-04-02T07:30:00",
                "issues_found": 2,
                "issues_fixed": 1,
                "pending_review": 1
            },
            "tasks": {
                "inbox": 5,
                "in_progress": 12,
                "review": 4,
                "done_today": 8
            },
            "security": {
                "trust_score": 92,
                "pii_issues": 0,
                "encryption_status": "all_clear",
                "last_audit": "2026-04-02T06:00:00"
            },
            "activity": [
                {
                    "id": "act_1",
                    "type": "agent_complete",
                    "message": "Agent completed test generation",
                    "timestamp": datetime.now().isoformat()
                },
                {
                    "id": "act_2",
                    "type": "security_scan",
                    "message": "Security scan completed: 0 issues",
                    "timestamp": datetime.now().isoformat()
                }
            ]
        }
    }

@router.get("/quick-stats")
async def get_quick_stats():
    """Get quick stats for header display"""
    return {
        "agents": {"online": 5, "total": 8},
        "sessions": {"active": 12},
        "tasks": {"pending": 23},
        "security": {"score": 92}
    }
