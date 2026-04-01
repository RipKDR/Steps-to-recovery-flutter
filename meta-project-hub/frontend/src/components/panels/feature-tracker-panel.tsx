'use client';

import { Flag, CheckCircle, Clock, Target } from 'lucide-react';

interface FeatureTrackerPanelProps {
  total?: number;
  completed?: number;
  inProgress?: number;
  planned?: number;
}

export function FeatureTrackerPanel({
  total = 19,
  completed = 14,
  inProgress = 3,
  planned = 2,
}: FeatureTrackerPanelProps) {
  const progress = (completed / total) * 100;

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-orange-500/10">
            <Flag className="text-orange-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Feature Tracker
            </h3>
            <p className="text-xs text-zinc-500">
              Recovery app features
            </p>
          </div>
        </div>
        <div className="p-2 rounded-lg bg-orange-500/10">
          <Target className="text-orange-500" size={20} />
        </div>
      </div>

      {/* Progress */}
      <div className="mb-6">
        <div className="flex justify-between text-sm mb-2">
          <span className="text-zinc-400">Completion</span>
          <span className="text-zinc-100 font-medium">
            {completed}/{total} ({Math.round(progress)}%)
          </span>
        </div>
        <div className="h-3 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-orange-500 to-amber-500 transition-all duration-500"
            style={{ width: `${progress}%` }}
          />
        </div>
      </div>

      {/* Status Grid */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-3 rounded-lg bg-emerald-500/10 border border-emerald-500/20">
          <div className="flex items-center gap-2 mb-1">
            <CheckCircle className="text-emerald-500" size={14} />
            <span className="text-xs text-emerald-400">Done</span>
          </div>
          <div className="text-xl font-bold text-emerald-400">{completed}</div>
        </div>

        <div className="p-3 rounded-lg bg-blue-500/10 border border-blue-500/20">
          <div className="flex items-center gap-2 mb-1">
            <Clock className="text-blue-500" size={14} />
            <span className="text-xs text-blue-400">In Progress</span>
          </div>
          <div className="text-xl font-bold text-blue-400">{inProgress}</div>
        </div>

        <div className="p-3 rounded-lg bg-zinc-800/50 border border-zinc-700">
          <div className="flex items-center gap-2 mb-1">
            <Target className="text-zinc-400" size={14} />
            <span className="text-xs text-zinc-400">Planned</span>
          </div>
          <div className="text-xl font-bold text-zinc-400">{planned}</div>
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-orange-500 hover:bg-orange-600 text-zinc-950 font-medium transition-colors">
          View Roadmap
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Details
        </button>
      </div>
    </div>
  );
}
