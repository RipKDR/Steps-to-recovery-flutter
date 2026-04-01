'use client';

import { Clock, Play, Pause, StopCircle } from 'lucide-react';

interface SessionTrackingPanelProps {
  activeSessions?: number;
  totalToday?: number;
  avgDuration?: string;
  sessions?: Array<{
    id: string;
    agent: string;
    duration: string;
    status: 'active' | 'completed' | 'failed';
  }>;
}

export function SessionTrackingPanel({
  activeSessions = 12,
  totalToday = 48,
  avgDuration = '8m 24s',
  sessions = [
    { id: '1', agent: 'flutter-widget-builder', duration: '12m 34s', status: 'active' },
    { id: '2', agent: 'security-specialist', duration: '5m 12s', status: 'active' },
    { id: '3', agent: 'service-architect', duration: '18m 45s', status: 'completed' },
    { id: '4', agent: 'ai-ml-integration', duration: '2m 18s', status: 'failed' },
  ],
}: SessionTrackingPanelProps) {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'text-emerald-400 bg-emerald-500/10';
      case 'completed':
        return 'text-blue-400 bg-blue-500/10';
      case 'failed':
        return 'text-red-400 bg-red-500/10';
    }
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-cyan-500/10">
            <Clock className="text-cyan-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Session Tracking
            </h3>
            <p className="text-xs text-zinc-500">
              {activeSessions} active sessions
            </p>
          </div>
        </div>
        <div className="flex gap-2">
          <button className="p-2 rounded-lg hover:bg-zinc-800 transition-colors">
            <Play className="text-emerald-500" size={18} />
          </button>
          <button className="p-2 rounded-lg hover:bg-zinc-800 transition-colors">
            <Pause className="text-amber-500" size={18} />
          </button>
          <button className="p-2 rounded-lg hover:bg-zinc-800 transition-colors">
            <StopCircle className="text-red-500" size={18} />
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="text-xs text-zinc-400 mb-1">Active</div>
          <div className="text-xl font-bold text-emerald-400">{activeSessions}</div>
        </div>

        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="text-xs text-zinc-400 mb-1">Today</div>
          <div className="text-xl font-bold text-blue-400">{totalToday}</div>
        </div>

        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="text-xs text-zinc-400 mb-1">Avg Duration</div>
          <div className="text-xl font-bold text-zinc-100">{avgDuration}</div>
        </div>
      </div>

      {/* Recent Sessions */}
      <div className="space-y-2 mb-6">
        {sessions.map((session) => (
          <div
            key={session.id}
            className="p-3 rounded-lg bg-zinc-800/50 hover:bg-zinc-800 transition-colors"
          >
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium text-zinc-100">{session.agent}</span>
              <span className={`text-xs px-2 py-1 rounded-full capitalize ${getStatusColor(session.status)}`}>
                {session.status}
              </span>
            </div>
            <div className="flex items-center gap-4 text-xs text-zinc-500">
              <span>ID: {session.id}</span>
              <span>Duration: {session.duration}</span>
            </div>
          </div>
        ))}
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-cyan-500 hover:bg-cyan-600 text-white font-medium transition-colors">
          View All Sessions
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Analytics
        </button>
      </div>
    </div>
  );
}
