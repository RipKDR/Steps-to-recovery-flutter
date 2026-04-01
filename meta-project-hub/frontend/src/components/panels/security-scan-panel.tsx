'use client';

import { Shield, AlertTriangle, CheckCircle, TrendingUp } from 'lucide-react';

interface SecurityScanPanelProps {
  trustScore?: number;
  issuesFound?: number;
  issuesFixed?: number;
  lastScan?: string;
}

export function SecurityScanPanel({
  trustScore = 92,
  issuesFound = 2,
  issuesFixed = 1,
  lastScan = new Date().toISOString(),
}: SecurityScanPanelProps) {
  const getTrustColor = (score: number) => {
    if (score >= 90) return 'text-emerald-500';
    if (score >= 70) return 'text-amber-500';
    return 'text-red-500';
  };

  const getTrustBg = (score: number) => {
    if (score >= 90) return 'bg-emerald-500/10 border-emerald-500/20';
    if (score >= 70) return 'bg-amber-500/10 border-amber-500/20';
    return 'bg-red-500/10 border-red-500/20';
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-red-500/10">
            <Shield className="text-red-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Security Scan
            </h3>
            <p className="text-xs text-zinc-500">
              Last scan: {new Date(lastScan).toLocaleTimeString()}
            </p>
          </div>
        </div>
        <div className={`px-3 py-1 rounded-full text-sm font-medium ${getTrustBg(trustScore)} ${getTrustColor(trustScore)}`}>
          Trust Score: {trustScore}
        </div>
      </div>

      {/* Trust Score */}
      <div className="mb-6">
        <div className="flex justify-between items-end mb-2">
          <span className="text-sm text-zinc-400">Overall Security</span>
          <span className={`text-3xl font-bold ${getTrustColor(trustScore)}`}>
            {trustScore}
          </span>
        </div>
        <div className="h-3 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className={`h-full transition-all duration-500 ${
              trustScore >= 90
                ? 'bg-gradient-to-r from-emerald-500 to-green-500'
                : trustScore >= 70
                ? 'bg-gradient-to-r from-amber-500 to-yellow-500'
                : 'bg-gradient-to-r from-red-500 to-orange-500'
            }`}
            style={{ width: `${trustScore}%` }}
          />
        </div>
      </div>

      {/* Issues Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <AlertTriangle className="text-red-500" size={16} />
            <span className="text-sm text-zinc-400">Issues Found</span>
          </div>
          <div className="text-2xl font-bold text-red-400">{issuesFound}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <CheckCircle className="text-emerald-500" size={16} />
            <span className="text-sm text-zinc-400">Issues Fixed</span>
          </div>
          <div className="text-2xl font-bold text-emerald-400">{issuesFixed}</div>
        </div>
      </div>

      {/* Fix Rate */}
      <div className="mb-6">
        <div className="flex justify-between text-sm mb-2">
          <span className="text-zinc-400">Auto-Fix Rate</span>
          <span className="text-zinc-100 font-medium">
            {issuesFound > 0 ? Math.round((issuesFixed / issuesFound) * 100) : 0}%
          </span>
        </div>
        <div className="h-2 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-blue-500 to-cyan-500 transition-all duration-500"
            style={{ width: `${issuesFound > 0 ? (issuesFixed / issuesFound) * 100 : 0}%` }}
          />
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-red-500 hover:bg-red-600 text-white font-medium transition-colors">
          Run Full Scan
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View Report
        </button>
      </div>
    </div>
  );
}
