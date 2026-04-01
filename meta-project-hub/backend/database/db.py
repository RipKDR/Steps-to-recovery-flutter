"""
Database Module

SQLite database with migrations.
Stores tasks, sessions, usage, memory, and configuration.
"""

import sqlite3
from pathlib import Path
from datetime import datetime

DATABASE_PATH = Path(__file__).parent / "meta_hub.db"

def get_connection():
    """Get database connection"""
    conn = sqlite3.connect(str(DATABASE_PATH))
    conn.row_factory = sqlite3.Row
    return conn

def initialize():
    """Initialize database tables"""
    conn = get_connection()
    cursor = conn.cursor()
    
    # Tasks table (Kanban board)
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            status TEXT DEFAULT 'inbox',
            priority TEXT DEFAULT 'medium',
            assigned_to TEXT,
            created_at TEXT,
            updated_at TEXT
        )
    ''')
    
    # Sessions table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            agent_id TEXT,
            started_at TEXT,
            ended_at TEXT,
            tokens_used INTEGER,
            cost REAL,
            status TEXT
        )
    ''')
    
    # Usage table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS usage_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            tokens INTEGER,
            cost REAL,
            agent_id TEXT
        )
    ''')
    
    # Memory table (semantic patterns)
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS memory_semantic (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pattern_id TEXT UNIQUE,
            name TEXT,
            category TEXT,
            confidence REAL,
            created_at TEXT
        )
    ''')
    
    # API keys table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS api_keys (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            key_hash TEXT,
            role TEXT,
            created_at TEXT,
            expires_at TEXT,
            active BOOLEAN DEFAULT 1
        )
    ''')
    
    conn.commit()
    conn.close()
    print("  📦 Database initialized")

def is_healthy() -> bool:
    """Check if database is healthy"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        conn.close()
        return True
    except:
        return False
