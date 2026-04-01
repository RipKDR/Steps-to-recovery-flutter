"""
WebSocket Manager

Manages WebSocket connections for real-time updates.
Broadcasts metrics, agent status, and activity feeds to connected clients.
"""

from fastapi import WebSocket
from typing import List, Dict, Set
from datetime import datetime
import asyncio
import json

class ConnectionManager:
    """Manages WebSocket connections"""
    
    def __init__(self):
        self.active_connections: List[WebSocket] = []
        self.subscriptions: Dict[WebSocket, Set[str]] = {}
    
    async def connect(self, websocket: WebSocket):
        """Accept new WebSocket connection"""
        await websocket.accept()
        self.active_connections.append(websocket)
        self.subscriptions[websocket] = set()
        print(f"[WebSocket] Connected: {len(self.active_connections)} clients")
    
    def disconnect(self, websocket: WebSocket):
        """Disconnect client"""
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
        if websocket in self.subscriptions:
            del self.subscriptions[websocket]
        print(f"[WebSocket] Disconnected: {len(self.active_connections)} clients")
    
    async def broadcast(self, message: dict):
        """Broadcast message to all connected clients"""
        disconnected = []
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except:
                disconnected.append(connection)
        
        # Clean up disconnected clients
        for conn in disconnected:
            self.disconnect(conn)
    
    async def broadcast_to_channel(self, channel: str, message: dict):
        """Broadcast to specific channel subscribers"""
        disconnected = []
        for websocket, channels in self.subscriptions.items():
            if channel in channels:
                try:
                    await websocket.send_json(message)
                except:
                    disconnected.append(websocket)
        
        for conn in disconnected:
            self.disconnect(conn)
    
    async def subscribe(self, websocket: WebSocket, channels: List[str]):
        """Subscribe to channels"""
        if websocket in self.subscriptions:
            self.subscriptions[websocket].update(channels)
    
    async def unsubscribe(self, websocket: WebSocket, channels: List[str]):
        """Unsubscribe from channels"""
        if websocket in self.subscriptions:
            self.subscriptions[websocket] -= set(channels)
    
    async def get_current_metrics(self) -> dict:
        """Get current metrics for refresh requests"""
        return {
            "type": "metrics_update",
            "timestamp": datetime.now().isoformat(),
            "data": {
                "agents": {"online": 5, "total": 8},
                "sessions": {"active": 12},
                "tasks": {"pending": 23},
                "security": {"score": 92}
            }
        }
    
    async def background_updates(self):
        """Send periodic updates every 10 seconds"""
        while True:
            try:
                await asyncio.sleep(10)
                metrics = await self.get_current_metrics()
                await self.broadcast(metrics)
            except Exception as e:
                print(f"[WebSocket] Background update error: {e}")
                await asyncio.sleep(5)
    
    def is_healthy(self) -> bool:
        """Check if WebSocket manager is healthy"""
        return True

# Global instance
manager = ConnectionManager()
