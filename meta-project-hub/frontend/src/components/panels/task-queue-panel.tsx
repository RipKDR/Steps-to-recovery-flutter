'use client';

import { Queue, Play, Pause, SkipForward } from 'lucide-react';

interface TaskQueuePanelProps {
  queued?: number;
  running?: number;
  completed?: number;
  failed?: number;
  currentTask?: {
    name: string;
    agent: string;
    progress: number;
    eta: string;
  };
}

export function TaskQueuePanel({
  queued = 8,
  running = 3,
  completed = 24,
  failed = 1,
  currentTask = {
    name: 'Generate test files',
    agent: 'flutter-test-architect',
    progress: 65,
    eta: '2m 30s',
  },
}: TaskQueuePanelProps) {
  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-violet-500/10">
            <Queue className="text-violet-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Task Queue
            </h3>
            <p className="text-xs text-zinc-500">
              {queued} queued • {running} running
            </p>
          </div>
        </div>
        <div className="flex gap-2">
          <button className="p-2 rounded-lg hover:bg-zinc-800 transition-colors">
            <Play className="text-emerald-500" size={18} />
          </button>
          <button className="p-2 rounded-lg hover:bg-zinc-800 transition-colors">
            <Pause className="text-amber-500" size={18} />
          </button>
          <button className="p-2 rounded-lg hover:bg-zinc-800 transition-colors">
            <SkipForward className="text-blue-500" size={18} />
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-3 mb-6">
        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="text-xs text-zinc-400 mb-1">Queued</div>
          <div className="text-lg font-bold text-zinc-100">{queued}</div>
        </div>

        <div className="p-3 rounded-lg bg-blue-500/10 border border-blue-500/20">
          <div className="text-xs text-blue-400 mb-1">Running</div>
          <div className="text-lg font-bold text-blue-400">{running}</div>
        </div>

        <div className="p-3 rounded-lg bg-emerald-500/10 border border-emerald-500/20">
          <div className="text-xs text-emerald-400 mb-1">Done</div>
          <div className="text-lg font-bold text-emerald-400">{completed}</div>
        </div>

        <div className="p-3 rounded-lg bg-red-500/10 border border-red-500/20">
          <div className="text-xs text-red-400 mb-1">Failed</div>
          <div className="text-lg font-bold text-red-400">{failed}</div>
        </div>
      </div>

      {/* Current Task */}
      {currentTask && (
        <div className="mb-6 p-4 rounded-lg bg-zinc-800/50 border border-zinc-700">
          <div className="flex items-center justify-between mb-3">
            <div>
              <h4 className="text-sm font-semibold text-zinc-100">{currentTask.name}</h4>
              <p className="text-xs text-zinc-500 mt-1">{currentTask.agent}</p>
            </div>
            <span className="text-xs text-zinc-400">ETA: {currentTask.eta}</span>
          </div>
          <div className="h-2 bg-zinc-700 rounded-full overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-violet-500 to-purple-500 transition-all duration-500"
              style={{ width: `${currentTask.progress}%` }}
            />
          </div>
          <div className="text-xs text-zinc-500 mt-2">{currentTask.progress}% complete</div>
        </div>
      )}

      {/* Queued Tasks */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Queued Tasks</div>
        <div className="space-y-2">
          <div className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between">
            <span className="text-sm text-zinc-300">Run security scan</span>
            <span className="text-xs text-zinc-500">security-specialist</span>
          </div>
          <div className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between">
            <span className="text-sm text-zinc-300">Fix lint errors</span>
            <span className="text-xs text-zinc-500">flutter-fix</span>
          </div>
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-violet-500 hover:bg-violet-600 text-white font-medium transition-colors">
          View Queue
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Add Task
        </button>
      </div>
    </div>
  );
}
