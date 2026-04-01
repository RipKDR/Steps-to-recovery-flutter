"""Tasks Router - Kanban board and task management"""
from fastapi import APIRouter
from datetime import datetime

router = APIRouter()

@router.get("/kanban")
async def get_kanban_board():
    """Get Kanban board with all columns"""
    return {
        "success": True,
        "data": {
            "columns": [
                {"id": "inbox", "name": "Inbox", "tasks": []},
                {"id": "assigned", "name": "Assigned", "tasks": []},
                {"id": "in_progress", "name": "In Progress", "tasks": []},
                {"id": "review", "name": "Review", "tasks": []},
                {"id": "quality", "name": "Quality Review", "tasks": []},
                {"id": "done", "name": "Done", "tasks": []}
            ]
        }
    }

@router.post("/create")
async def create_task():
    """Create a new task"""
    return {"success": True, "message": "Task created"}
