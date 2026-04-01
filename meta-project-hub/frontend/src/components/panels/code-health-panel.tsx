'use client';

import { FlaskConical, TrendingUp, AlertCircle, CheckCircle } from 'lucide-react';

interface CodeHealthPanelProps {
  score?: number;
  errors?: number;
  warnings?: number;
  analyzedAt?: string;
}

export function CodeHealthPanel({
  score = 98,
  errors = 0,
  warnings = 3,
  analyzedAt = new Date().toISOString(),
}: CodeHealthPanelProps) {
  const getStatusColor = (score: number) => {
    if (score >= 90) return 'text-emerald-500';
    if (score >= 70) return 'text-amber-500';
    return 'text-red-500';
  };

  const getStatusBg = (score: number) => {
    if (score >= 90) return 'bg-emerald-500/10 border-emerald-500/20';
    if (score >= 70) return 'bg-amber-500/10 border-amber-500/20';
    return 'bg-red-500/10 border-red-500/20';
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-cyan-500/10">
            <FlaskConical className="text-cyan-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Code Health
            </h3>
            <p className="text-xs text-zinc-500">
              Last analyzed: {new Date(analyzedAt).toLocaleTimeString()}
            </p>
          </div>
        </div>
        <div className={`px-3 py-1 rounded-full text-sm font-medium ${getStatusBg(score)} ${getStatusColor(score)}`}>
          {score >= 90 ? 'Excellent' : score >= 70 ? 'Good' : 'Needs Work'}
        </div>
      </div>

      {/* Score */}
      <div className="mb-6">
        <div className="flex justify-between items-end mb-2">
          <span className="text-sm text-zinc-400">Overall Score</span>
          <span className={`text-3xl font-bold ${getStatusColor(score)}`}>
            {score}
          </span>
        </div>
        <div className="h-3 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className={`h-full transition-all duration-500 ${
              score >= 90
                ? 'bg-gradient-to-r from-emerald-500 to-green-500'
                : score >= 70
                ? 'bg-gradient-to-r from-amber-500 to-yellow-500'
                : 'bg-gradient-to-r from-red-500 to-orange-500'
            }`}
            style={{ width: `${score}%` }}
          />
        </div>
      </div>

      {/* Metrics */}
      <div className="grid grid-cols-2 gap-4">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <AlertCircle className="text-red-500" size={16} />
            <span className="text-sm text-zinc-400">Errors</span>
          </div>
          <div className="text-2xl font-bold text-zinc-100">{errors}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <AlertCircle className="text-amber-500" size={16} />
            <span className="text-sm text-zinc-400">Warnings</span>
          </div>
          <div className="text-2xl font-bold text-zinc-100">{warnings}</div>
        </div>
      </div>

      {/* Actions */}
      <div className="mt-6 flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-cyan-500 hover:bg-cyan-600 text-zinc-950 font-medium transition-colors">
          Run Analysis
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View Details
        </button>
      </div>
    </div>
  );
}
