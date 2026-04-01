'use client';

import { Gauge, TrendingUp, AlertTriangle } from 'lucide-react';

interface PerformancePanelProps {
  appSize?: string;
  loadTime?: string;
  jankCount?: number;
  frameBudget?: number;
}

export function PerformancePanel({
  appSize = '45.2 MB',
  loadTime = '1.2s',
  jankCount = 3,
  frameBudget = 94,
}: PerformancePanelProps) {
  const getJankStatus = () => {
    if (jankCount === 0) return { color: 'text-emerald-400', label: 'Excellent' };
    if (jankCount < 5) return { color: 'text-amber-400', label: 'Good' };
    return { color: 'text-red-400', label: 'Poor' };
  };

  const jankStatus = getJankStatus();

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-green-500/10">
            <Gauge className="text-green-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Performance
            </h3>
            <p className="text-xs text-zinc-500">
              App metrics
            </p>
          </div>
        </div>
        <div className="p-2 rounded-lg bg-green-500/10">
          <TrendingUp className="text-green-500" size={20} />
        </div>
      </div>

      {/* Metrics Grid */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="text-sm text-zinc-400 mb-1">App Size</div>
          <div className="text-xl font-bold text-zinc-100">{appSize}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="text-sm text-zinc-400 mb-1">Load Time</div>
          <div className="text-xl font-bold text-zinc-100">{loadTime}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="text-sm text-zinc-400 mb-1">Jank Count</div>
          <div className={`text-xl font-bold ${jankStatus.color}`}>
            {jankCount}
          </div>
          <div className="text-xs text-zinc-500">{jankStatus.label}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="text-sm text-zinc-400 mb-1">Frame Budget</div>
          <div className="text-xl font-bold text-emerald-400">{frameBudget}%</div>
        </div>
      </div>

      {/* Frame Budget Progress */}
      <div className="mb-6">
        <div className="flex justify-between text-sm mb-2">
          <span className="text-zinc-400">Frame Budget Usage</span>
          <span className="text-zinc-100 font-medium">{frameBudget}%</span>
        </div>
        <div className="h-2 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className={`h-full transition-all duration-500 ${
              frameBudget >= 90
                ? 'bg-gradient-to-r from-emerald-500 to-green-500'
                : frameBudget >= 70
                ? 'bg-gradient-to-r from-amber-500 to-yellow-500'
                : 'bg-gradient-to-r from-red-500 to-orange-500'
            }`}
            style={{ width: `${frameBudget}%` }}
          />
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-green-500 hover:bg-green-600 text-white font-medium transition-colors">
          Run Profile
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          DevTools
        </button>
      </div>
    </div>
  );
}
