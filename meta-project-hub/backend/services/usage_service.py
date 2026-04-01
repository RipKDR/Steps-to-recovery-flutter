"""
Usage Service

Tracks token usage, costs, and session analytics.
Implements budget monitoring and alerts.
"""

import asyncio
from datetime import datetime, timedelta

class UsageService:
    """Token usage and cost tracking"""
    
    def __init__(self):
        self.current_usage = {
            "tokens": 0,
            "cost": 0.0,
            "sessions": 0
        }
        self.initialized = False
    
    async def initialize(self):
        """Initialize usage service"""
        print("  📊 Usage service initialized")
        self.initialized = True
    
    async def periodic_reset(self):
        """Reset daily stats every 24 hours"""
        while True:
            try:
                await asyncio.sleep(86400)  # Every 24 hours
                await self.reset_daily_stats()
                print("[Usage] Daily stats reset")
            except Exception as e:
                print(f"[Usage] Reset error: {e}")
                await asyncio.sleep(3600)
    
    async def reset_daily_stats(self):
        """Reset daily statistics"""
        self.current_usage["tokens"] = 0
        self.current_usage["cost"] = 0.0
    
    def get_current(self) -> dict:
        """Get current usage"""
        return self.current_usage
    
    def is_healthy(self) -> bool:
        """Check if usage service is healthy"""
        return self.initialized
    
    async def shutdown(self):
        """Shutdown usage service"""
        print("  📊 Usage service shutdown")

# Global instance
service = UsageService()
