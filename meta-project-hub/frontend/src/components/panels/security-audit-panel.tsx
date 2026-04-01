'use client';

import { FileSearch, AlertTriangle, ShieldAlert, CheckCircle } from 'lucide-react';

interface SecurityAuditPanelProps {
  lastAudit?: string;
  nextAudit?: string;
  findings?: {
    critical: number;
    high: number;
    medium: number;
    low: number;
  };
  overallScore?: number;
  recentAudits?: Array<{
    date: string;
    type: string;
    score: number;
    findings: number;
  }>;
}

export function SecurityAuditPanel({
  lastAudit = new Date().toISOString(),
  nextAudit = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
  findings = { critical: 0, high: 2, medium: 5, low: 8 },
  overallScore = 92,
  recentAudits = [
    { date: '2026-04-01', type: 'Full Security Scan', score: 92, findings: 15 },
    { date: '2026-03-15', type: 'PII Detection', score: 96, findings: 3 },
    { date: '2026-03-01', type: 'Encryption Audit', score: 100, findings: 0 },
    { date: '2026-02-15', type: 'Access Control', score: 88, findings: 8 },
  ],
}: SecurityAuditPanelProps) {
  const getScoreColor = (score: number) => {
    if (score >= 90) return 'text-emerald-400';
    if (score >= 70) return 'text-amber-400';
    return 'text-red-400';
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-red-500/10">
            <FileSearch className="text-red-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Security Audit
            </h3>
            <p className="text-xs text-zinc-500">
              Last: {new Date(lastAudit).toLocaleDateString()}
            </p>
          </div>
        </div>
        <div className={`px-3 py-1 rounded-full text-sm font-bold ${
          overallScore >= 90 ? 'bg-emerald-500/10 text-emerald-400' :
          overallScore >= 70 ? 'bg-amber-500/10 text-amber-400' :
          'bg-red-500/10 text-red-400'
        }`}>
          Score: {overallScore}
        </div>
      </div>

      {/* Overall Score */}
      <div className="mb-6">
        <div className="flex justify-between items-end mb-2">
          <span className="text-sm text-zinc-400">Security Posture</span>
          <span className={`text-3xl font-bold ${getScoreColor(overallScore)}`}>
            {overallScore}
          </span>
        </div>
        <div className="h-3 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className={`h-full transition-all duration-500 ${
              overallScore >= 90
                ? 'bg-gradient-to-r from-emerald-500 to-green-500'
                : overallScore >= 70
                ? 'bg-gradient-to-r from-amber-500 to-yellow-500'
                : 'bg-gradient-to-r from-red-500 to-orange-500'
            }`}
            style={{ width: `${overallScore}%` }}
          />
        </div>
      </div>

      {/* Findings */}
      <div className="grid grid-cols-4 gap-3 mb-6">
        <div className="p-3 rounded-lg bg-red-500/10 border border-red-500/20">
          <div className="flex items-center gap-2 mb-2">
            <ShieldAlert className="text-red-500" size={14} />
            <span className="text-xs text-red-400">Critical</span>
          </div>
          <div className="text-xl font-bold text-red-400">{findings.critical}</div>
        </div>

        <div className="p-3 rounded-lg bg-orange-500/10 border border-orange-500/20">
          <div className="flex items-center gap-2 mb-2">
            <AlertTriangle className="text-orange-500" size={14} />
            <span className="text-xs text-orange-400">High</span>
          </div>
          <div className="text-xl font-bold text-orange-400">{findings.high}</div>
        </div>

        <div className="p-3 rounded-lg bg-amber-500/10 border border-amber-500/20">
          <div className="flex items-center gap-2 mb-2">
            <AlertTriangle className="text-amber-500" size={14} />
            <span className="text-xs text-amber-400">Medium</span>
          </div>
          <div className="text-xl font-bold text-amber-400">{findings.medium}</div>
        </div>

        <div className="p-3 rounded-lg bg-blue-500/10 border border-blue-500/20">
          <div className="flex items-center gap-2 mb-2">
            <FileSearch className="text-blue-500" size={14} />
            <span className="text-xs text-blue-400">Low</span>
          </div>
          <div className="text-xl font-bold text-blue-400">{findings.low}</div>
        </div>
      </div>

      {/* Recent Audits */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Recent Audits</div>
        <div className="space-y-2">
          {recentAudits.map((audit, index) => (
            <div
              key={index}
              className="p-3 rounded-lg bg-zinc-800/50 hover:bg-zinc-800 transition-colors cursor-pointer"
            >
              <div className="flex items-center justify-between mb-2">
                <h4 className="text-sm font-medium text-zinc-100">{audit.type}</h4>
                <span className={`text-sm font-bold ${getScoreColor(audit.score)}`}>
                  {audit.score}
                </span>
              </div>
              <div className="flex items-center justify-between text-xs text-zinc-500">
                <span>{new Date(audit.date).toLocaleDateString()}</span>
                <span>{audit.findings} findings</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Next Audit */}
      <div className="mb-6 p-4 rounded-lg bg-indigo-500/10 border border-indigo-500/20">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <CheckCircle className="text-indigo-500" size={16} />
            <span className="text-sm text-indigo-400">Next Scheduled Audit</span>
          </div>
          <span className="text-sm font-medium text-indigo-100">
            {new Date(nextAudit).toLocaleDateString()}
          </span>
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-red-500 hover:bg-red-600 text-white font-medium transition-colors">
          Run Audit
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View History
        </button>
      </div>
    </div>
  );
}
