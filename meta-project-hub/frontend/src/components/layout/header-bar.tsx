'use client';

import { Bell, RefreshCw, Wifi, WifiOff } from 'lucide-react';
import { useDashboardStore } from '@/store/dashboard-store';

export function HeaderBar() {
  const {
    websocketConnected,
    metrics,
    loading,
    fetchMetrics,
  } = useDashboardStore();

  return (
    <header className="h-16 bg-zinc-900/50 backdrop-blur border-b border-zinc-800 flex items-center justify-between px-6 sticky top-0 z-40">
      {/* Left - Title */}
      <div>
        <h1 className="text-zinc-100 font-semibold">
          Meta Project HUB
        </h1>
        <p className="text-xs text-zinc-500">
          AI Agent Orchestration Platform
        </p>
      </div>

      {/* Center - Quick Stats */}
      <div className="flex items-center gap-6">
        {metrics && (
          <>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-emerald-500" />
              <span className="text-sm text-zinc-400">
                {metrics.agents.online}/{metrics.agents.total} Agents
              </span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-blue-500" />
              <span className="text-sm text-zinc-400">
                {metrics.sessions.active} Sessions
              </span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-amber-500" />
              <span className="text-sm text-zinc-400">
                {metrics.tasks.pending} Tasks
              </span>
            </div>
          </>
        )}
      </div>

      {/* Right - Actions */}
      <div className="flex items-center gap-3">
        {/* WebSocket Status */}
        <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-zinc-800/50">
          {websocketConnected ? (
            <Wifi size={14} className="text-emerald-500" />
          ) : (
            <WifiOff size={14} className="text-red-500" />
          )}
          <span className="text-xs text-zinc-400">
            {websocketConnected ? 'Live' : 'Offline'}
          </span>
        </div>

        {/* Refresh */}
        <button
          onClick={fetchMetrics}
          disabled={loading}
          className="p-2 rounded-lg hover:bg-zinc-800 transition-colors disabled:opacity-50"
          title="Refresh metrics"
        >
          <RefreshCw
            size={18}
            className={`text-zinc-400 ${loading ? 'animate-spin' : ''}`}
          />
        </button>

        {/* Notifications */}
        <button className="p-2 rounded-lg hover:bg-zinc-800 transition-colors relative">
          <Bell size={18} className="text-zinc-400" />
          <span className="absolute top-1 right-1 w-2 h-2 rounded-full bg-red-500" />
        </button>
      </div>
    </header>
  );
}
