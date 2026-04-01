"""Usage Router - Token tracking and cost analytics"""
from fastapi import APIRouter
from datetime import datetime

router = APIRouter()

@router.get("/current")
async def get_current_usage():
    """Get current token usage"""
    return {"success": True, "data": {"tokens": 0, "cost": 0.0}}

@router.get("/history")
async def get_usage_history():
    """Get usage history"""
    return {"success": True, "data": {"history": []}}
