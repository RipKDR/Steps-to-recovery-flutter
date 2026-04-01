'use client';

import { Award, TrendingUp, Target, Star } from 'lucide-react';

interface AgentEvalsPanelProps {
  overallScore?: number;
  evals?: {
    output: { score: number; total: number };
    trace: { score: number; total: number };
    latency: { p50: string; p95: string; p99: string };
    drift: { detected: boolean; threshold: number; current: number };
  };
}

export function AgentEvalsPanel({
  overallScore = 87,
  evals = {
    output: { score: 92, total: 100 },
    trace: { score: 88, total: 100 },
    latency: { p50: '1.2s', p95: '2.8s', p99: '4.1s' },
    drift: { detected: false, threshold: 10, current: 3.2 },
  },
}: AgentEvalsPanelProps) {
  const getGrade = (score: number) => {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  };

  const getColor = (score: number) => {
    if (score >= 90) return 'text-emerald-400 bg-emerald-500/10';
    if (score >= 80) return 'text-blue-400 bg-blue-500/10';
    if (score >= 70) return 'text-amber-400 bg-amber-500/10';
    return 'text-red-400 bg-red-500/10';
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-indigo-500/10">
            <Award className="text-indigo-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Agent Evals
            </h3>
            <p className="text-xs text-zinc-500">
              Performance evaluation
            </p>
          </div>
        </div>
        <div className={`px-3 py-1 rounded-full text-sm font-bold ${getColor(overallScore)}`}>
          Grade: {getGrade(overallScore)}
        </div>
      </div>

      {/* Overall Score */}
      <div className="mb-6">
        <div className="flex justify-between items-end mb-2">
          <span className="text-sm text-zinc-400">Overall Performance</span>
          <span className={`text-3xl font-bold ${getColor(overallScore).split(' ')[0]}`}>
            {overallScore}
          </span>
        </div>
        <div className="h-3 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className={`h-full transition-all duration-500 ${
              overallScore >= 90
                ? 'bg-gradient-to-r from-emerald-500 to-green-500'
                : overallScore >= 80
                ? 'bg-gradient-to-r from-blue-500 to-cyan-500'
                : 'bg-gradient-to-r from-amber-500 to-orange-500'
            }`}
            style={{ width: `${overallScore}%` }}
          />
        </div>
      </div>

      {/* Eval Metrics */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <Star className="text-yellow-500" size={14} />
            <span className="text-sm text-zinc-400">Output Quality</span>
          </div>
          <div className="text-2xl font-bold text-yellow-400">{evals.output.score}</div>
          <div className="text-xs text-zinc-500">of {evals.output.total}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <Target className="text-purple-500" size={14} />
            <span className="text-sm text-zinc-400">Trace Quality</span>
          </div>
          <div className="text-2xl font-bold text-purple-400">{evals.trace.score}</div>
          <div className="text-xs text-zinc-500">of {evals.trace.total}</div>
        </div>
      </div>

      {/* Latency */}
      <div className="mb-6 p-4 rounded-lg bg-zinc-800/50">
        <div className="text-sm text-zinc-400 mb-3">Latency Percentiles</div>
        <div className="grid grid-cols-3 gap-3">
          <div>
            <div className="text-xs text-zinc-500 mb-1">P50</div>
            <div className="text-lg font-bold text-zinc-100">{evals.latency.p50}</div>
          </div>
          <div>
            <div className="text-xs text-zinc-500 mb-1">P95</div>
            <div className="text-lg font-bold text-zinc-100">{evals.latency.p95}</div>
          </div>
          <div>
            <div className="text-xs text-zinc-500 mb-1">P99</div>
            <div className="text-lg font-bold text-zinc-100">{evals.latency.p99}</div>
          </div>
        </div>
      </div>

      {/* Drift Detection */}
      <div className="mb-6 p-4 rounded-lg bg-zinc-800/50">
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2">
            <TrendingUp className="text-zinc-400" size={14} />
            <span className="text-sm text-zinc-400">Drift Detection</span>
          </div>
          <span className={`text-xs px-2 py-1 rounded-full ${
            evals.drift.detected
              ? 'bg-red-500/10 text-red-400'
              : 'bg-emerald-500/10 text-emerald-400'
          }`}>
            {evals.drift.detected ? 'Detected' : 'Normal'}
          </span>
        </div>
        <div className="flex justify-between text-xs text-zinc-500">
          <span>Threshold: {evals.drift.threshold}%</span>
          <span>Current: {evals.drift.current}%</span>
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-indigo-500 hover:bg-indigo-600 text-white font-medium transition-colors">
          Run Evaluation
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View Report
        </button>
      </div>
    </div>
  );
}
