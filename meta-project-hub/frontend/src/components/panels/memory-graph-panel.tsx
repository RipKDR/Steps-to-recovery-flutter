'use client';

import { Brain, Network, GitBranch, TrendingUp } from 'lucide-react';

interface MemoryGraphPanelProps {
  totalNodes?: number;
  totalEdges?: number;
  semanticCount?: number;
  episodicCount?: number;
  workingCount?: number;
  recentConnections?: Array<{
    from: string;
    to: string;
    strength: number;
  }>;
}

export function MemoryGraphPanel({
  totalNodes = 156,
  totalEdges = 342,
  semanticCount = 48,
  episodicCount = 89,
  workingCount = 19,
  recentConnections = [
    { from: 'fastapi-patterns', to: 'python-backend', strength: 0.95 },
    { from: 'nextjs-app-router', to: 'tailwind-design', strength: 0.88 },
    { from: 'websocket-realtime', to: 'dashboard-updates', strength: 0.92 },
  ],
}: MemoryGraphPanelProps) {
  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-amber-500/10">
            <Brain className="text-amber-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Memory Graph
            </h3>
            <p className="text-xs text-zinc-500">
              Knowledge network visualization
            </p>
          </div>
        </div>
        <div className="p-2 rounded-lg bg-amber-500/10">
          <Network className="text-amber-500" size={20} />
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <GitBranch className="text-zinc-400" size={14} />
            <span className="text-sm text-zinc-400">Total Nodes</span>
          </div>
          <div className="text-2xl font-bold text-zinc-100">{totalNodes}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <Network className="text-zinc-400" size={14} />
            <span className="text-sm text-zinc-400">Connections</span>
          </div>
          <div className="text-2xl font-bold text-zinc-100">{totalEdges}</div>
        </div>
      </div>

      {/* Memory Types */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-3 rounded-lg bg-blue-500/10 border border-blue-500/20">
          <div className="text-xs text-blue-400 mb-1">Semantic</div>
          <div className="text-lg font-bold text-blue-400">{semanticCount}</div>
        </div>

        <div className="p-3 rounded-lg bg-purple-500/10 border border-purple-500/20">
          <div className="text-xs text-purple-400 mb-1">Episodic</div>
          <div className="text-lg font-bold text-purple-400">{episodicCount}</div>
        </div>

        <div className="p-3 rounded-lg bg-green-500/10 border border-green-500/20">
          <div className="text-xs text-green-400 mb-1">Working</div>
          <div className="text-lg font-bold text-green-400">{workingCount}</div>
        </div>
      </div>

      {/* Recent Connections */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Strong Connections</div>
        <div className="space-y-2">
          {recentConnections.map((conn, index) => (
            <div key={index} className="p-3 rounded-lg bg-zinc-800/50">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <span className="text-sm text-zinc-300">{conn.from}</span>
                  <GitBranch className="text-zinc-500" size={12} />
                  <span className="text-sm text-zinc-300">{conn.to}</span>
                </div>
                <div className="flex items-center gap-1 text-xs text-amber-400">
                  <TrendingUp size={12} />
                  <span>{Math.round(conn.strength * 100)}%</span>
                </div>
              </div>
              <div className="h-1.5 bg-zinc-700 rounded-full overflow-hidden">
                <div
                  className="h-full bg-gradient-to-r from-amber-500 to-orange-500"
                  style={{ width: `${conn.strength * 100}%` }}
                />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-amber-500 hover:bg-amber-600 text-white font-medium transition-colors">
          Visualize Graph
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Explore
        </button>
      </div>
    </div>
  );
}
