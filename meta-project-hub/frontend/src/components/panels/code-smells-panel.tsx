'use client';

import { Bug, AlertTriangle, CheckCircle, Clock } from 'lucide-react';

interface CodeSmellsPanelProps {
  total?: number;
  critical?: number;
  major?: number;
  minor?: number;
}

export function CodeSmellsPanel({
  total = 12,
  critical = 1,
  major = 4,
  minor = 7,
}: CodeSmellsPanelProps) {
  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-purple-500/10">
            <Bug className="text-purple-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Code Smells
            </h3>
            <p className="text-xs text-zinc-500">
              Technical debt
            </p>
          </div>
        </div>
        <div className="px-3 py-1 rounded-full text-sm font-medium bg-purple-500/10 text-purple-400 border border-purple-500/20">
          {total} Total
        </div>
      </div>

      {/* Severity Grid */}
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
            <Clock className="text-blue-500" size={16} />
            <span className="text-xs text-blue-400">Minor</span>
          </div>
          <div className="text-2xl font-bold text-blue-400">{minor}</div>
        </div>
      </div>

      {/* Top Issues */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Top Issues</div>
        <div className="space-y-2">
          <div className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between">
            <span className="text-sm text-zinc-300">Long methods (&gt;50 lines)</span>
            <span className="text-xs text-red-400 font-medium">Critical</span>
          </div>
          <div className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between">
            <span className="text-sm text-zinc-300">God classes</span>
            <span className="text-xs text-amber-400 font-medium">Major</span>
          </div>
          <div className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between">
            <span className="text-sm text-zinc-300">Unused imports</span>
            <span className="text-xs text-blue-400 font-medium">Minor</span>
          </div>
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-purple-500 hover:bg-purple-600 text-white font-medium transition-colors">
          Auto-Fix Safe
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View All
        </button>
      </div>
    </div>
  );
}
