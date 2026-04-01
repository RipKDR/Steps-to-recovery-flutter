'use client';

import { Bug, AlertTriangle, CheckCircle, TrendingDown } from 'lucide-react';

interface BugTrackerPanelProps {
  totalBugs?: number;
  critical?: number;
  major?: number;
  minor?: number;
  resolvedThisWeek?: number;
  trend?: 'up' | 'down' | 'stable';
}

export function BugTrackerPanel({
  totalBugs = 23,
  critical = 2,
  major = 8,
  minor = 13,
  resolvedThisWeek = 12,
  trend = 'down',
}: BugTrackerPanelProps) {
  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-red-500/10">
            <Bug className="text-red-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Bug Tracker
            </h3>
            <p className="text-xs text-zinc-500">
              {totalBugs} active bugs
            </p>
          </div>
        </div>
        <div className={`flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium ${
          trend === 'down' ? 'bg-emerald-500/10 text-emerald-400' :
          trend === 'up' ? 'bg-red-500/10 text-red-400' :
          'bg-zinc-700 text-zinc-400'
        }`}>
          {trend === 'down' && <TrendingDown size={12} />}
          {trend === 'down' ? 'Improving' : trend === 'up' ? 'Worsening' : 'Stable'}
        </div>
      </div>

      {/* Severity Breakdown */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-4 rounded-lg bg-red-500/10 border border-red-500/20">
          <div className="flex items-center gap-2 mb-2">
            <AlertTriangle className="text-red-500" size={16} />
            <span className="text-xs text-red-400">Critical</span>
          </div>
          <div className="text-2xl font-bold text-red-400">{critical}</div>
        </div>

        <div className="p-4 rounded-lg bg-amber-500/10 border border-amber-500/20">
          <div className="flex items-center gap-2 mb-2">
            <AlertTriangle className="text-amber-500" size={16} />
            <span className="text-xs text-amber-400">Major</span>
          </div>
          <div className="text-2xl font-bold text-amber-400">{major}</div>
        </div>

        <div className="p-4 rounded-lg bg-blue-500/10 border border-blue-500/20">
          <div className="flex items-center gap-2 mb-2">
            <Bug className="text-blue-500" size={16} />
            <span className="text-xs text-blue-400">Minor</span>
          </div>
          <div className="text-2xl font-bold text-blue-400">{minor}</div>
        </div>
      </div>

      {/* Resolved This Week */}
      <div className="mb-6 p-4 rounded-lg bg-emerald-500/10 border border-emerald-500/20">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <CheckCircle className="text-emerald-500" size={18} />
            <span className="text-sm text-emerald-400">Resolved This Week</span>
          </div>
          <span className="text-2xl font-bold text-emerald-400">{resolvedThisWeek}</span>
        </div>
      </div>

      {/* Recent Bugs */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Recent Bugs</div>
        <div className="space-y-2">
          <div className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-2 h-2 rounded-full bg-red-500" />
              <span className="text-sm text-zinc-300">App crashes on sponsor chat open</span>
            </div>
            <span className="text-xs text-red-400 font-medium">Critical</span>
          </div>
          <div className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-2 h-2 rounded-full bg-amber-500" />
              <span className="text-sm text-zinc-300">Memory not persisting after restart</span>
            </div>
            <span className="text-xs text-amber-400 font-medium">Major</span>
          </div>
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-red-500 hover:bg-red-600 text-white font-medium transition-colors">
          Report Bug
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View All
        </button>
      </div>
    </div>
  );
}
