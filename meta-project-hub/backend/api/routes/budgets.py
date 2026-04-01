"""Budgets Router - Budget limits and alerts"""
from fastapi import APIRouter

router = APIRouter()

@router.get("/list")
async def list_budgets():
    """List all budgets"""
    return {"success": True, "data": {"budgets": []}}

@router.post("/create")
async def create_budget():
    """Create a new budget"""
    return {"success": True, "message": "Budget created"}
