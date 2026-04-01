'use client';

import { CheckCircle, XCircle, Clock, Activity } from 'lucide-react';

interface CICDStatusPanelProps {
  lastBuild?: 'success' | 'failure' | 'running';
  lastDeploy?: 'success' | 'failure' | 'pending';
  passRate?: number;
  lastRun?: string;
}

export function CICDStatusPanel({
  lastBuild = 'success',
  lastDeploy = 'success',
  passRate = 98,
  lastRun = new Date().toISOString(),
}: CICDStatusPanelProps) {
  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'success':
        return <CheckCircle className="text-emerald-500" size={20} />;
      case 'failure':
        return <XCircle className="text-red-500" size={20} />;
      case 'running':
      case 'pending':
        return <Clock className="text-blue-500 animate-pulse" size={20} />;
    }
  };

  const recentRuns = [
    { id: 1, name: 'ci.yml', status: 'success', duration: '3m 24s', time: '1 hour ago' },
    { id: 2, name: 'pr_check.yml', status: 'success', duration: '2m 12s', time: '3 hours ago' },
    { id: 3, name: 'security.yml', status: 'running', duration: '1m 45s', time: 'Running' },
  ];

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-orange-500/10">
            <Activity className="text-orange-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              CI/CD Status
            </h3>
            <p className="text-xs text-zinc-500">
              Last run: {new Date(lastRun).toLocaleTimeString()}
            </p>
          </div>
        </div>
        <div className="px-3 py-1 rounded-full text-sm font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
          {passRate}% Pass Rate
        </div>
      </div>

      {/* Build & Deploy Status */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center justify-between mb-3">
            <span className="text-sm text-zinc-400">Last Build</span>
            {getStatusIcon(lastBuild)}
          </div>
          <div className={`text-lg font-bold capitalize ${
            lastBuild === 'success' ? 'text-emerald-400' :
            lastBuild === 'failure' ? 'text-red-400' :
            'text-blue-400'
          }`}>
            {lastBuild}
          </div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center justify-between mb-3">
            <span className="text-sm text-zinc-400">Last Deploy</span>
            {getStatusIcon(lastDeploy)}
          </div>
          <div className={`text-lg font-bold capitalize ${
            lastDeploy === 'success' ? 'text-emerald-400' :
            lastDeploy === 'failure' ? 'text-red-400' :
            'text-blue-400'
          }`}>
            {lastDeploy}
          </div>
        </div>
      </div>

      {/* Pass Rate */}
      <div className="mb-6">
        <div className="flex justify-between text-sm mb-2">
          <span className="text-zinc-400">Pipeline Pass Rate</span>
          <span className="text-zinc-100 font-medium">{passRate}%</span>
        </div>
        <div className="h-2 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-orange-500 to-amber-500 transition-all duration-500"
            style={{ width: `${passRate}%` }}
          />
        </div>
      </div>

      {/* Recent Runs */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Recent Runs</div>
        <div className="space-y-2">
          {recentRuns.map((run) => (
            <div
              key={run.id}
              className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between"
            >
              <div className="flex items-center gap-3">
                {getStatusIcon(run.status)}
                <span className="text-sm text-zinc-300">{run.name}</span>
              </div>
              <div className="flex items-center gap-4">
                <span className="text-xs text-zinc-500">{run.duration}</span>
                <span className="text-xs text-zinc-500">{run.time}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-orange-500 hover:bg-orange-600 text-white font-medium transition-colors">
          Trigger Build
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View Logs
        </button>
      </div>
    </div>
  );
}
