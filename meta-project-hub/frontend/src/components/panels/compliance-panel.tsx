'use client';

import { ClipboardCheck, FileCheck, ShieldCheck, AlertTriangle } from 'lucide-react';

interface CompliancePanelProps {
  overallCompliance?: number;
  frameworks?: Array<{
    name: string;
    compliance: number;
    status: 'compliant' | 'partial' | 'non_compliant';
  }>;
  issues?: Array<{
    framework: string;
    requirement: string;
    severity: 'critical' | 'major' | 'minor';
    status: 'open' | 'in_progress' | 'resolved';
  }>;
}

export function CompliancePanel({
  overallCompliance = 94,
  frameworks = [
    { name: 'GDPR', compliance: 96, status: 'compliant' },
    { name: 'HIPAA', compliance: 92, status: 'partial' },
    { name: 'CCPA', compliance: 98, status: 'compliant' },
    { name: 'Privacy-First', compliance: 100, status: 'compliant' },
  ],
  issues = [
    { framework: 'HIPAA', requirement: 'Audit logging enhancement', severity: 'major', status: 'in_progress' },
    { framework: 'GDPR', requirement: 'Data export feature', severity: 'minor', status: 'open' },
  ],
}: CompliancePanelProps) {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'compliant':
        return 'text-emerald-400 bg-emerald-500/10 border-emerald-500/20';
      case 'partial':
        return 'text-amber-400 bg-amber-500/10 border-amber-500/20';
      case 'non_compliant':
        return 'text-red-400 bg-red-500/10 border-red-500/20';
    }
  };

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'critical':
        return 'text-red-400 bg-red-500/10';
      case 'major':
        return 'text-amber-400 bg-amber-500/10';
      case 'minor':
        return 'text-blue-400 bg-blue-500/10';
    }
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-indigo-500/10">
            <ClipboardCheck className="text-indigo-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Compliance
            </h3>
            <p className="text-xs text-zinc-500">
              Regulatory compliance tracking
            </p>
          </div>
        </div>
        <div className="px-3 py-1 rounded-full text-sm font-medium bg-indigo-500/10 text-indigo-400 border border-indigo-500/20">
          {overallCompliance}% Compliant
        </div>
      </div>

      {/* Overall Progress */}
      <div className="mb-6">
        <div className="flex justify-between text-sm mb-2">
          <span className="text-zinc-400">Overall Compliance</span>
          <span className="text-zinc-100 font-medium">{overallCompliance}%</span>
        </div>
        <div className="h-3 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-indigo-500 to-purple-500 transition-all duration-500"
            style={{ width: `${overallCompliance}%` }}
          />
        </div>
      </div>

      {/* Frameworks */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Frameworks</div>
        <div className="space-y-2">
          {frameworks.map((fw, index) => (
            <div
              key={index}
              className={`p-3 rounded-lg border ${getStatusColor(fw.status)}`}
            >
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <ShieldCheck size={16} />
                  <span className="text-sm font-medium">{fw.name}</span>
                </div>
                <span className="text-xs font-medium capitalize">{fw.status.replace('_', ' ')}</span>
              </div>
              <div className="h-1.5 bg-zinc-700 rounded-full overflow-hidden">
                <div
                  className={`h-full ${
                    fw.compliance >= 95 ? 'bg-emerald-500' :
                    fw.compliance >= 80 ? 'bg-amber-500' :
                    'bg-red-500'
                  }`}
                  style={{ width: `${fw.compliance}%` }}
                />
              </div>
              <div className="text-xs mt-1">{fw.compliance}% compliant</div>
            </div>
          ))}
        </div>
      </div>

      {/* Open Issues */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Open Issues</div>
        <div className="space-y-2">
          {issues.map((issue, index) => (
            <div
              key={index}
              className="p-3 rounded-lg bg-zinc-800/50 hover:bg-zinc-800 transition-colors cursor-pointer"
            >
              <div className="flex items-start justify-between mb-2">
                <div>
                  <h4 className="text-sm font-medium text-zinc-100">{issue.requirement}</h4>
                  <p className="text-xs text-zinc-500 mt-1">{issue.framework}</p>
                </div>
                <div className="flex items-center gap-2">
                  <span className={`text-xs px-2 py-1 rounded-full capitalize ${getSeverityColor(issue.severity)}`}>
                    {issue.severity}
                  </span>
                  <span className={`text-xs px-2 py-1 rounded-full capitalize ${
                    issue.status === 'resolved' ? 'bg-emerald-500/10 text-emerald-400' :
                    issue.status === 'in_progress' ? 'bg-blue-500/10 text-blue-400' :
                    'bg-zinc-700 text-zinc-400'
                  }`}>
                    {issue.status}
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-indigo-500 hover:bg-indigo-600 text-white font-medium transition-colors">
          Run Assessment
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View Report
        </button>
      </div>
    </div>
  );
}
