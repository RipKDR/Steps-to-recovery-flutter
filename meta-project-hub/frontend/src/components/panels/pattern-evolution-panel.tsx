'use client';

import { TrendingUp, GitMerge, AlertTriangle, CheckCircle } from 'lucide-react';

interface PatternEvolutionPanelProps {
  totalUpdates?: number;
  corrections?: number;
  newPatterns?: number;
  deprecated?: number;
  recentEvolutions?: Array<{
    date: string;
    type: 'new' | 'update' | 'correction' | 'deprecated';
    pattern: string;
    confidence: number;
  }>;
}

export function PatternEvolutionPanel({
  totalUpdates = 156,
  corrections = 8,
  newPatterns = 24,
  deprecated = 3,
  recentEvolutions = [
    { date: '2026-04-02', type: 'new', pattern: 'meta-project-hub-architecture', confidence: 0.95 },
    { date: '2026-04-01', type: 'update', pattern: 'fastapi-templates', confidence: 0.98 },
    { date: '2026-03-31', type: 'correction', pattern: 'websocket-realtime', confidence: 0.92 },
    { date: '2026-03-30', type: 'new', pattern: 'nextjs-app-router', confidence: 0.96 },
  ],
}: PatternEvolutionPanelProps) {
  const getTypeColor = (type: string) => {
    switch (type) {
      case 'new':
        return 'text-emerald-400 bg-emerald-500/10';
      case 'update':
        return 'text-blue-400 bg-blue-500/10';
      case 'correction':
        return 'text-amber-400 bg-amber-500/10';
      case 'deprecated':
        return 'text-red-400 bg-red-500/10';
    }
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'new':
        return <CheckCircle size={14} />;
      case 'update':
        return <TrendingUp size={14} />;
      case 'correction':
        return <AlertTriangle size={14} />;
      case 'deprecated':
        return <GitMerge size={14} />;
    }
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-orange-500/10">
            <TrendingUp className="text-orange-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Pattern Evolution
            </h3>
            <p className="text-xs text-zinc-500">
              Continuous improvement tracking
            </p>
          </div>
        </div>
        <div className="px-3 py-1 rounded-full text-xs font-medium bg-orange-500/10 text-orange-400 border border-orange-500/20">
          {totalUpdates} updates
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-3 mb-6">
        <div className="p-3 rounded-lg bg-emerald-500/10 border border-emerald-500/20">
          <div className="text-xs text-emerald-400 mb-1">New</div>
          <div className="text-lg font-bold text-emerald-400">{newPatterns}</div>
        </div>

        <div className="p-3 rounded-lg bg-blue-500/10 border border-blue-500/20">
          <div className="text-xs text-blue-400 mb-1">Updated</div>
          <div className="text-lg font-bold text-blue-400">{totalUpdates - newPatterns - corrections - deprecated}</div>
        </div>

        <div className="p-3 rounded-lg bg-amber-500/10 border border-amber-500/20">
          <div className="text-xs text-amber-400 mb-1">Corrected</div>
          <div className="text-lg font-bold text-amber-400">{corrections}</div>
        </div>

        <div className="p-3 rounded-lg bg-red-500/10 border border-red-500/20">
          <div className="text-xs text-red-400 mb-1">Deprecated</div>
          <div className="text-lg font-bold text-red-400">{deprecated}</div>
        </div>
      </div>

      {/* Recent Evolutions */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Recent Changes</div>
        <div className="space-y-2">
          {recentEvolutions.map((evo, index) => (
            <div
              key={index}
              className="p-3 rounded-lg bg-zinc-800/50 hover:bg-zinc-800 transition-colors"
            >
              <div className="flex items-start justify-between mb-2">
                <div className="flex items-center gap-2">
                  <span className={`p-1 rounded ${getTypeColor(evo.type)}`}>
                    {getTypeIcon(evo.type)}
                  </span>
                  <div>
                    <h4 className="text-sm font-medium text-zinc-100">{evo.pattern}</h4>
                    <p className="text-xs text-zinc-500 mt-1">
                      {new Date(evo.date).toLocaleDateString()}
                    </p>
                  </div>
                </div>
                <span className={`text-xs px-2 py-1 rounded-full capitalize ${getTypeColor(evo.type)}`}>
                  {evo.type}
                </span>
              </div>
              <div className="flex items-center gap-2 text-xs text-zinc-500">
                <span>Confidence: {Math.round(evo.confidence * 100)}%</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-orange-500 hover:bg-orange-600 text-white font-medium transition-colors">
          View Timeline
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Export Report
        </button>
      </div>
    </div>
  );
}
