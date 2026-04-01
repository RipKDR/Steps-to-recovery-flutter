'use client';

import { Wand2, CheckCircle, Clock, RotateCcw } from 'lucide-react';

interface AutoFixLogPanelProps {
  totalFixed?: number;
  successRate?: number;
  lastFix?: string;
  rollbacks?: number;
}

export function AutoFixLogPanel({
  totalFixed = 24,
  successRate = 96,
  lastFix = new Date().toISOString(),
  rollbacks = 1,
}: AutoFixLogPanelProps) {
  const recentFixes = [
    { id: 1, issue: 'Removed unused imports', time: '2 min ago', status: 'success' },
    { id: 2, issue: 'Fixed missing await', time: '15 min ago', status: 'success' },
    { id: 3, issue: 'Formatted code', time: '1 hour ago', status: 'success' },
    { id: 4, issue: 'Added missing return', time: '2 hours ago', status: 'rollback' },
  ];

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-green-500/10">
            <Wand2 className="text-green-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Auto-Fix Log
            </h3>
            <p className="text-xs text-zinc-500">
              Last fix: {new Date(lastFix).toLocaleTimeString()}
            </p>
          </div>
        </div>
        <div className="px-3 py-1 rounded-full text-sm font-medium bg-green-500/10 text-green-400 border border-green-500/20">
          {successRate}% Success
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <CheckCircle className="text-emerald-500" size={16} />
            <span className="text-sm text-zinc-400">Total Fixed</span>
          </div>
          <div className="text-2xl font-bold text-emerald-400">{totalFixed}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <RotateCcw className="text-amber-500" size={16} />
            <span className="text-sm text-zinc-400">Rollbacks</span>
          </div>
          <div className="text-2xl font-bold text-amber-400">{rollbacks}</div>
        </div>
      </div>

      {/* Success Rate */}
      <div className="mb-6">
        <div className="flex justify-between text-sm mb-2">
          <span className="text-zinc-400">Success Rate</span>
          <span className="text-zinc-100 font-medium">{successRate}%</span>
        </div>
        <div className="h-2 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-green-500 to-emerald-500 transition-all duration-500"
            style={{ width: `${successRate}%` }}
          />
        </div>
      </div>

      {/* Recent Fixes */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Recent Activity</div>
        <div className="space-y-2">
          {recentFixes.map((fix) => (
            <div
              key={fix.id}
              className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between"
            >
              <div className="flex items-center gap-3">
                {fix.status === 'success' ? (
                  <CheckCircle className="text-emerald-500" size={14} />
                ) : (
                  <RotateCcw className="text-amber-500" size={14} />
                )}
                <span className="text-sm text-zinc-300">{fix.issue}</span>
              </div>
              <span className="text-xs text-zinc-500">{fix.time}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-green-500 hover:bg-green-600 text-white font-medium transition-colors">
          Run Auto-Fix
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View Log
        </button>
      </div>
    </div>
  );
}
