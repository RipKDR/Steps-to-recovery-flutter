'use client';

import { TestTube, CheckCircle, XCircle } from 'lucide-react';

interface TestCoveragePanelProps {
  coverage?: number;
  totalFiles?: number;
  testedFiles?: number;
  target?: number;
}

export function TestCoveragePanel({
  coverage = 67.5,
  totalFiles = 156,
  testedFiles = 105,
  target = 80,
}: TestCoveragePanelProps) {
  const progress = Math.min(100, (coverage / target) * 100);
  const isTargetMet = coverage >= target;

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-purple-500/10">
            <TestTube className="text-purple-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Test Coverage
            </h3>
            <p className="text-xs text-zinc-500">
              Target: {target}%
            </p>
          </div>
        </div>
        <div className={`p-2 rounded-lg ${isTargetMet ? 'bg-emerald-500/10' : 'bg-amber-500/10'}`}>
          {isTargetMet ? (
            <CheckCircle className="text-emerald-500" size={20} />
          ) : (
            <XCircle className="text-amber-500" size={20} />
          )}
        </div>
      </div>

      {/* Coverage */}
      <div className="mb-6">
        <div className="flex justify-between items-end mb-2">
          <span className="text-sm text-zinc-400">Coverage</span>
          <span className="text-3xl font-bold text-zinc-100">
            {coverage}%
          </span>
        </div>
        <div className="h-3 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className={`h-full transition-all duration-500 ${
              isTargetMet
                ? 'bg-gradient-to-r from-emerald-500 to-green-500'
                : 'bg-gradient-to-r from-purple-500 to-pink-500'
            }`}
            style={{ width: `${progress}%` }}
          />
        </div>
        <div className="flex justify-between mt-2 text-xs">
          <span className="text-zinc-500">0%</span>
          <span className="text-zinc-500">{target}% (target)</span>
          <span className="text-zinc-500">100%</span>
        </div>
      </div>

      {/* File Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="text-sm text-zinc-400 mb-1">Tested Files</div>
          <div className="text-2xl font-bold text-emerald-400">
            {testedFiles}
          </div>
          <div className="text-xs text-zinc-500">of {totalFiles} total</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="text-sm text-zinc-400 mb-1">Untested</div>
          <div className="text-2xl font-bold text-amber-400">
            {totalFiles - testedFiles}
          </div>
          <div className="text-xs text-zinc-500">
            {Math.round(((totalFiles - testedFiles) / totalFiles) * 100)}% of total
          </div>
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-purple-500 hover:bg-purple-600 text-white font-medium transition-colors">
          Generate Tests
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View Files
        </button>
      </div>
    </div>
  );
}
