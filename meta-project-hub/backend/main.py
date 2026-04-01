"""
Meta Project HUB - FastAPI Backend

A production-grade AI agent orchestration platform combining:
- Mission Control architecture (32 panels, WebSocket, SQLite)
- MUTX-DEV operations (governance, sessions, usage, AARM compliance)
- Flutter app integration (Steps to Recovery metrics)
- Meta-Systems Hub (17 PowerShell scripts)
- Self-Evolving Agent (continuous improvement)

Version: 1.0.0
"""

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
from datetime import datetime
from pathlib import Path
import asyncio
import sys

# Add backend to path
sys.path.append(str(Path(__file__).parent))

# Import routes
from api.routes import (
    auth,
    agents,
    sessions,
    usage,
    budgets,
    governance,
    flutter,
    meta_systems,
    tasks,
    memory,
    security,
    monitoring,
    dashboard
)

# Import services
from services import (
    websocket_manager,
    memory_service,
    usage_service
)

# Import database
from database import db

# Configuration
PROJECT_ROOT = Path(__file__).parent.parent.parent
HUB_ROOT = Path(__file__).parent
BACKEND_ROOT = Path(__file__).parent

# Lifespan context manager
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    # Startup
    print("\n" + "="*70)
    print("  Meta Project HUB - FastAPI Backend")
    print("="*70)
    print(f"\n  Version: 1.0.0")
    print(f"  Project Root: {PROJECT_ROOT}")
    print(f"  Hub Root: {HUB_ROOT}")
    print("\n  🚀 Starting server...")
    
    # Initialize database
    print("  📦 Initializing database...")
    db.initialize()
    
    # Initialize services
    print("  🔧 Initializing services...")
    await memory_service.initialize()
    await usage_service.initialize()
    
    # Start background tasks
    print("  ⚙️  Starting background tasks...")
    asyncio.create_task(websocket_manager.background_updates())
    asyncio.create_task(memory_service.periodic_consolidation())
    asyncio.create_task(usage_service.periodic_reset())
    
    print("\n  ✅ Server ready!")
    print("\n  📊 Dashboard: http://localhost:8000")
    print("  📖 API Docs: http://localhost:8000/docs")
    print("  🔌 WebSocket: ws://localhost:8000/ws")
    print("\n  Press Ctrl+C to stop\n")
    
    yield
    
    # Shutdown
    print("\n  🛑 Shutting down...")
    await memory_service.shutdown()
    await usage_service.shutdown()
    print("  ✅ Shutdown complete")

# Create FastAPI app
app = FastAPI(
    title="Meta Project HUB",
    description="""
## AI Agent Orchestration Platform

A production-grade dashboard for managing AI agents, Flutter app development, and Meta-Systems.

### Features

- **32 Panels** - Comprehensive monitoring and management
- **Real-time Updates** - WebSocket + SSE
- **Governance Engine** - Faramesh-inspired policy system
- **Usage Analytics** - Token tracking, budgets, costs
- **Flutter Integration** - Code health, tests, builds
- **Meta-Systems** - 17 PowerShell scripts integration
- **Self-Evolving** - Continuous improvement from sessions

### API Structure

All API routes are under `/v1/*` prefix:

- `/v1/auth` - Authentication
- `/v1/agents` - Agent management
- `/v1/sessions` - Session tracking
- `/v1/usage` - Token/cost analytics
- `/v1/budgets` - Budget limits
- `/v1/governance` - Policy engine
- `/v1/flutter` - Flutter metrics
- `/v1/meta-systems` - Meta-Systems Hub
- `/v1/tasks` - Kanban board
- `/v1/memory` - Self-improving memory
- `/v1/security` - Security audit
- `/v1/monitoring` - OpenTelemetry
    """,
    version="1.0.0",
    lifespan=lifespan
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",  # Next.js frontend
        "http://localhost:8000",  # Local development
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/v1/auth", tags=["Authentication"])
app.include_router(agents.router, prefix="/v1/agents", tags=["Agents"])
app.include_router(sessions.router, prefix="/v1/sessions", tags=["Sessions"])
app.include_router(usage.router, prefix="/v1/usage", tags=["Usage Analytics"])
app.include_router(budgets.router, prefix="/v1/budgets", tags=["Budgets"])
app.include_router(governance.router, prefix="/v1/governance", tags=["Governance"])
app.include_router(flutter.router, prefix="/v1/flutter", tags=["Flutter App"])
app.include_router(meta_systems.router, prefix="/v1/meta-systems", tags=["Meta-Systems"])
app.include_router(tasks.router, prefix="/v1/tasks", tags=["Task Management"])
app.include_router(memory.router, prefix="/v1/memory", tags=["Memory & Learning"])
app.include_router(security.router, prefix="/v1/security", tags=["Security"])
app.include_router(monitoring.router, prefix="/v1/monitoring", tags=["Monitoring"])
app.include_router(dashboard.router, prefix="/v1/dashboard", tags=["Dashboard"])

# WebSocket endpoint
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """
    WebSocket connection for real-time updates.
    
    Connects clients to receive live metrics, agent status, and activity feeds.
    """
    await websocket_manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_json()
            
            # Handle ping/pong
            if data.get("type") == "ping":
                await websocket.send_json({
                    "type": "pong",
                    "timestamp": datetime.now().isoformat()
                })
            
            # Handle refresh requests
            elif data.get("type") == "refresh_request":
                metrics = await websocket_manager.get_current_metrics()
                await websocket.send_json(metrics)
            
            # Handle subscription changes
            elif data.get("type") == "subscribe":
                channels = data.get("channels", [])
                await websocket_manager.subscribe(websocket, channels)
            
            # Handle unsubscription
            elif data.get("type") == "unsubscribe":
                channels = data.get("channels", [])
                await websocket_manager.unsubscribe(websocket, channels)
                
    except WebSocketDisconnect:
        websocket_manager.disconnect(websocket)
    except Exception as e:
        print(f"[WebSocket] Error: {e}")
        websocket_manager.disconnect(websocket)

# Serve frontend
@app.get("/", response_class=HTMLResponse)
async def serve_frontend():
    """Serve the dashboard frontend"""
    dashboard_html = HUB_ROOT / "frontend" / "build" / "index.html"
    if dashboard_html.exists():
        return FileResponse(str(dashboard_html))
    
    # Fallback to simple dashboard
    simple_dashboard = BACKEND_ROOT / "dashboard.html"
    if simple_dashboard.exists():
        return FileResponse(str(simple_dashboard))
    
    return HTMLResponse(content="""
        <h1>Meta Project HUB</h1>
        <p>Frontend not built. Run: npm run build in frontend directory.</p>
        <p>API Docs: <a href="/docs">/docs</a></p>
    """)

# Health check
@app.get("/health", tags=["Health"])
async def health_check():
    """
    Health check endpoint.
    
    Returns current server status and component health.
    """
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0",
        "components": {
            "api": "healthy",
            "database": db.is_healthy(),
            "websocket": websocket_manager.is_healthy(),
            "memory": memory_service.is_healthy(),
            "usage": usage_service.is_healthy()
        }
    }

# Ready check (for Kubernetes/load balancers)
@app.get("/ready", tags=["Health"])
async def ready_check():
    """
    Readiness check endpoint.
    
    Returns true if the server is ready to accept traffic.
    """
    is_ready = (
        db.is_healthy() and
        websocket_manager.is_healthy() and
        memory_service.is_healthy()
    )
    
    if is_ready:
        return {"ready": True}
    else:
        raise HTTPException(status_code=503, detail="Service not ready")

# Metrics endpoint (for Prometheus/OpenTelemetry)
@app.get("/metrics", tags=["Monitoring"])
async def metrics_endpoint():
    """
    Prometheus-compatible metrics endpoint.
    
    Returns metrics in OpenMetrics format.
    """
    from services import monitoring_service
    
    metrics = monitoring_service.get_prometheus_metrics()
    return HTMLResponse(
        content=metrics,
        media_type="text/plain; version=0.0.4"
    )

# Root info
@app.get("/info", tags=["Info"])
async def root_info():
    """
    Root endpoint with API information.
    """
    return {
        "name": "Meta Project HUB",
        "version": "1.0.0",
        "description": "AI Agent Orchestration Platform",
        "docs": "/docs",
        "health": "/health",
        "metrics": "/metrics",
        "websocket": "/ws"
    }

if __name__ == "__main__":
    import uvicorn
    
    print("\n" + "="*70)
    print("  Meta Project HUB - Development Server")
    print("="*70)
    print("\n  Starting on http://0.0.0.0:8000")
    print("  API Docs: http://0.0.0.0:8000/docs")
    print("\n  Press Ctrl+C to stop\n")
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
