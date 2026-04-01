'use client';

import { PackageOpen, AlertTriangle, TrendingUp } from 'lucide-react';

interface DependenciesPanelProps {
  total?: number;
  outdated?: number;
  vulnerable?: number;
  latest?: number;
}

export function DependenciesPanel({
  total = 45,
  outdated = 8,
  vulnerable = 0,
  latest = 37,
}: DependenciesPanelProps) {
  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-blue-500/10">
            <PackageOpen className="text-blue-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Dependencies
            </h3>
            <p className="text-xs text-zinc-500">
              pub.dev packages
            </p>
          </div>
        </div>
        {vulnerable > 0 ? (
          <div className="p-2 rounded-lg bg-red-500/10">
            <AlertTriangle className="text-red-500" size={20} />
          </div>
        ) : (
          <div className="p-2 rounded-lg bg-emerald-500/10">
            <TrendingUp className="text-emerald-500" size={20} />
          </div>
        )}
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="text-sm text-zinc-400 mb-1">Total</div>
          <div className="text-2xl font-bold text-zinc-100">{total}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="text-sm text-zinc-400 mb-1">Latest</div>
          <div className="text-2xl font-bold text-emerald-400">{latest}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="text-sm text-zinc-400 mb-1">Outdated</div>
          <div className="text-2xl font-bold text-amber-400">{outdated}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="text-sm text-zinc-400 mb-1">Vulnerable</div>
          <div className={`text-2xl font-bold ${vulnerable > 0 ? 'text-red-400' : 'text-emerald-400'}`}>
            {vulnerable}
          </div>
        </div>
      </div>

      {/* Freshness Score */}
      <div className="mb-6">
        <div className="flex justify-between text-sm mb-2">
          <span className="text-zinc-400">Freshness Score</span>
          <span className="text-zinc-100 font-medium">
            {Math.round((latest / total) * 100)}%
          </span>
        </div>
        <div className="h-2 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-blue-500 to-cyan-500 transition-all duration-500"
            style={{ width: `${(latest / total) * 100}%` }}
          />
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-blue-500 hover:bg-blue-600 text-white font-medium transition-colors">
          Update All
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View Details
        </button>
      </div>
    </div>
  );
}
