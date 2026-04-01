'use client';

import { Cpu, Wifi, WifiOff, Activity } from 'lucide-react';

interface AgentStatusPanelProps {
  agents?: Array<{
    id: string;
    name: string;
    status: 'online' | 'offline' | 'busy' | 'idle';
    uptime: string;
  }>;
  total?: number;
  online?: number;
}

export function AgentStatusPanel({
  agents = [
    { id: '1', name: 'flutter-test-architect', status: 'online', uptime: '2h 34m' },
    { id: '2', name: 'security-specialist', status: 'busy', uptime: '4h 12m' },
    { id: '3', name: 'service-architect', status: 'idle', uptime: '1h 45m' },
    { id: '4', name: 'ai-ml-integration', status: 'offline', uptime: '0m' },
  ],
  total = 8,
  online = 5,
}: AgentStatusPanelProps) {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'online':
        return 'text-emerald-400 bg-emerald-500/10';
      case 'busy':
        return 'text-blue-400 bg-blue-500/10';
      case 'idle':
        return 'text-amber-400 bg-amber-500/10';
      case 'offline':
        return 'text-zinc-400 bg-zinc-700';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'online':
        return <Wifi size={14} className="text-emerald-500" />;
      case 'busy':
        return <Activity size={14} className="text-blue-500" />;
      case 'idle':
        return <Wifi size={14} className="text-amber-500" />;
      case 'offline':
        return <WifiOff size={14} className="text-zinc-500" />;
    }
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-indigo-500/10">
            <Cpu className="text-indigo-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Agent Status
            </h3>
            <p className="text-xs text-zinc-500">
              {online}/{total} agents online
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
          <span className="text-xs text-emerald-400">Healthy</span>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-3 mb-6">
        <div className="p-3 rounded-lg bg-emerald-500/10 border border-emerald-500/20">
          <div className="text-xs text-emerald-400 mb-1">Online</div>
          <div className="text-xl font-bold text-emerald-400">
            {agents.filter(a => a.status === 'online').length}
          </div>
        </div>

        <div className="p-3 rounded-lg bg-blue-500/10 border border-blue-500/20">
          <div className="text-xs text-blue-400 mb-1">Busy</div>
          <div className="text-xl font-bold text-blue-400">
            {agents.filter(a => a.status === 'busy').length}
          </div>
        </div>

        <div className="p-3 rounded-lg bg-amber-500/10 border border-amber-500/20">
          <div className="text-xs text-amber-400 mb-1">Idle</div>
          <div className="text-xl font-bold text-amber-400">
            {agents.filter(a => a.status === 'idle').length}
          </div>
        </div>

        <div className="p-3 rounded-lg bg-zinc-800/50 border border-zinc-700">
          <div className="text-xs text-zinc-400 mb-1">Offline</div>
          <div className="text-xl font-bold text-zinc-400">
            {agents.filter(a => a.status === 'offline').length}
          </div>
        </div>
      </div>

      {/* Agents List */}
      <div className="space-y-2 mb-6">
        {agents.map((agent) => (
          <div
            key={agent.id}
            className="p-3 rounded-lg bg-zinc-800/50 hover:bg-zinc-800 transition-colors cursor-pointer"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                {getStatusIcon(agent.status)}
                <span className="text-sm font-medium text-zinc-100">{agent.name}</span>
              </div>
              <span className={`text-xs px-2 py-1 rounded-full capitalize ${getStatusColor(agent.status)}`}>
                {agent.status}
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-indigo-500 hover:bg-indigo-600 text-white font-medium transition-colors">
          Manage Agents
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View Logs
        </button>
      </div>
    </div>
  );
}
