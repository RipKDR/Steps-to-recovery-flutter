'use client';

import { GitBranch, GitCommit, GitPullRequest, Clock } from 'lucide-react';

interface GitStatusPanelProps {
  branch?: string;
  commitsAhead?: number;
  commitsBehind?: number;
  modified?: number;
  untracked?: number;
  lastCommit?: string;
}

export function GitStatusPanel({
  branch = 'main',
  commitsAhead = 2,
  commitsBehind = 0,
  modified = 5,
  untracked = 3,
  lastCommit = new Date().toISOString(),
}: GitStatusPanelProps) {
  const hasChanges = modified > 0 || untracked > 0 || commitsAhead > 0;

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-blue-500/10">
            <GitBranch className="text-blue-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Git Status
            </h3>
            <p className="text-xs text-zinc-500">
              {branch} • {new Date(lastCommit).toLocaleDateString()}
            </p>
          </div>
        </div>
        <div className={`px-3 py-1 rounded-full text-xs font-medium ${
          hasChanges
            ? 'bg-amber-500/10 text-amber-400 border border-amber-500/20'
            : 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
        }`}>
          {hasChanges ? 'Has Changes' : 'Clean'}
        </div>
      </div>

      {/* Branch Info */}
      <div className="mb-6 p-4 rounded-lg bg-zinc-800/50">
        <div className="flex items-center justify-between mb-3">
          <span className="text-sm text-zinc-400">Current Branch</span>
          <span className="text-lg font-bold text-zinc-100">{branch}</span>
        </div>
        <div className="flex gap-4">
          <div className="flex items-center gap-2">
            <GitCommit className="text-emerald-500" size={14} />
            <span className="text-sm text-zinc-400">Ahead:</span>
            <span className="text-sm font-bold text-emerald-400">{commitsAhead}</span>
          </div>
          <div className="flex items-center gap-2">
            <GitCommit className="text-red-500" size={14} />
            <span className="text-sm text-zinc-400">Behind:</span>
            <span className="text-sm font-bold text-red-400">{commitsBehind}</span>
          </div>
        </div>
      </div>

      {/* File Changes */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <GitCommit className="text-amber-500" size={16} />
            <span className="text-sm text-zinc-400">Modified</span>
          </div>
          <div className="text-2xl font-bold text-amber-400">{modified}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <Clock className="text-blue-500" size={16} />
            <span className="text-sm text-zinc-400">Untracked</span>
          </div>
          <div className="text-2xl font-bold text-blue-400">{untracked}</div>
        </div>
      </div>

      {/* Actions */}
      <div className="grid grid-cols-2 gap-3">
        <button className="px-4 py-2 rounded-lg bg-blue-500 hover:bg-blue-600 text-white font-medium transition-colors">
          Commit
        </button>
        <button className="px-4 py-2 rounded-lg bg-emerald-500 hover:bg-emerald-600 text-white font-medium transition-colors">
          Push
        </button>
        <button className="px-4 py-2 rounded-lg bg-purple-500 hover:bg-purple-600 text-white font-medium transition-colors">
          Pull
        </button>
        <button className="px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          History
        </button>
      </div>
    </div>
  );
}
