'use client';

import { Target, TrendingUp, Calendar, CheckCircle } from 'lucide-react';

interface SprintPlanningPanelProps {
  sprintNumber?: number;
  daysRemaining?: number;
  storyPoints?: {
    total: number;
    completed: number;
    inProgress: number;
    todo: number;
  };
  velocity?: number;
}

export function SprintPlanningPanel({
  sprintNumber = 12,
  daysRemaining = 8,
  storyPoints = { total: 42, completed: 18, inProgress: 12, todo: 12 },
  velocity = 38,
}: SprintPlanningPanelProps) {
  const progress = (storyPoints.completed / storyPoints.total) * 100;

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-green-500/10">
            <Target className="text-green-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Sprint Planning
            </h3>
            <p className="text-xs text-zinc-500">
              Sprint #{sprintNumber} • {daysRemaining} days left
            </p>
          </div>
        </div>
        <div className="px-3 py-1 rounded-full text-xs font-medium bg-green-500/10 text-green-400 border border-green-500/20">
          On Track
        </div>
      </div>

      {/* Days Remaining */}
      <div className="mb-6 p-4 rounded-lg bg-zinc-800/50">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <Calendar className="text-zinc-400" size={18} />
            <span className="text-sm text-zinc-400">Days Remaining</span>
          </div>
          <span className="text-2xl font-bold text-zinc-100">{daysRemaining}</span>
        </div>
        <div className="h-2 bg-zinc-700 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-green-500 to-emerald-500 transition-all duration-500"
            style={{ width: `${(daysRemaining / 14) * 100}%` }}
          />
        </div>
      </div>

      {/* Story Points */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-3 rounded-lg bg-emerald-500/10 border border-emerald-500/20">
          <div className="flex items-center gap-2 mb-2">
            <CheckCircle className="text-emerald-500" size={14} />
            <span className="text-xs text-emerald-400">Done</span>
          </div>
          <div className="text-xl font-bold text-emerald-400">{storyPoints.completed}</div>
        </div>

        <div className="p-3 rounded-lg bg-amber-500/10 border border-amber-500/20">
          <div className="flex items-center gap-2 mb-2">
            <TrendingUp className="text-amber-500" size={14} />
            <span className="text-xs text-amber-400">In Progress</span>
          </div>
          <div className="text-xl font-bold text-amber-400">{storyPoints.inProgress}</div>
        </div>

        <div className="p-3 rounded-lg bg-zinc-800/50 border border-zinc-700">
          <div className="flex items-center gap-2 mb-2">
            <Target className="text-zinc-400" size={14} />
            <span className="text-xs text-zinc-400">Todo</span>
          </div>
          <div className="text-xl font-bold text-zinc-400">{storyPoints.todo}</div>
        </div>
      </div>

      {/* Velocity */}
      <div className="mb-6">
        <div className="flex justify-between text-sm mb-2">
          <span className="text-zinc-400">Sprint Progress</span>
          <span className="text-zinc-100 font-medium">{Math.round(progress)}%</span>
        </div>
        <div className="h-2 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-green-500 to-blue-500 transition-all duration-500"
            style={{ width: `${progress}%` }}
          />
        </div>
        <div className="flex justify-between mt-2 text-xs text-zinc-500">
          <span>Velocity: {velocity} pts/sprint</span>
          <span>Total: {storyPoints.total} pts</span>
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-green-500 hover:bg-green-600 text-white font-medium transition-colors">
          View Sprint
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Edit Board
        </button>
      </div>
    </div>
  );
}
