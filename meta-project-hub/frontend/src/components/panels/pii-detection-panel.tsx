'use client';

import { Eye, AlertTriangle, Shield, FileSearch } from 'lucide-react';

interface PIIDetectionPanelProps {
  totalScanned?: number;
  issuesFound?: number;
  issuesFixed?: number;
  riskLevel?: 'low' | 'medium' | 'high';
  recentDetections?: Array<{
    file: string;
    type: 'email' | 'phone' | 'password' | 'token';
    severity: 'critical' | 'warning' | 'info';
    status: 'fixed' | 'pending' | 'ignored';
  }>;
}

export function PIIDetectionPanel({
  totalScanned = 1247,
  issuesFound = 5,
  issuesFixed = 4,
  riskLevel = 'low',
  recentDetections = [
    { file: 'lib/core/services/ai_service.dart', type: 'token', severity: 'critical', status: 'fixed' },
    { file: 'lib/features/auth/screens/login_screen.dart', type: 'password', severity: 'critical', status: 'fixed' },
    { file: 'lib/core/utils/logger.dart', type: 'email', severity: 'warning', status: 'pending' },
    { file: 'test/sponsor_service_test.dart', type: 'phone', severity: 'info', status: 'ignored' },
  ],
}: PIIDetectionPanelProps) {
  const getRiskColor = (level: string) => {
    switch (level) {
      case 'low':
        return 'text-emerald-400 bg-emerald-500/10';
      case 'medium':
        return 'text-amber-400 bg-amber-500/10';
      case 'high':
        return 'text-red-400 bg-red-500/10';
    }
  };

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'critical':
        return 'text-red-400 bg-red-500/10';
      case 'warning':
        return 'text-amber-400 bg-amber-500/10';
      case 'info':
        return 'text-blue-400 bg-blue-500/10';
    }
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-red-500/10">
            <Eye className="text-red-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              PII Detection
            </h3>
            <p className="text-xs text-zinc-500">
              {totalScanned} files scanned
            </p>
          </div>
        </div>
        <div className={`px-3 py-1 rounded-full text-xs font-medium ${getRiskColor(riskLevel)}`}>
          Risk: {riskLevel}
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="text-xs text-zinc-400 mb-1">Issues Found</div>
          <div className="text-xl font-bold text-red-400">{issuesFound}</div>
        </div>

        <div className="p-3 rounded-lg bg-emerald-500/10 border border-emerald-500/20">
          <div className="text-xs text-emerald-400 mb-1">Fixed</div>
          <div className="text-xl font-bold text-emerald-400">{issuesFixed}</div>
        </div>

        <div className="p-3 rounded-lg bg-amber-500/10 border border-amber-500/20">
          <div className="text-xs text-amber-400 mb-1">Pending</div>
          <div className="text-xl font-bold text-amber-400">{issuesFound - issuesFixed}</div>
        </div>
      </div>

      {/* Recent Detections */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Recent Detections</div>
        <div className="space-y-2">
          {recentDetections.map((detection, index) => (
            <div
              key={index}
              className="p-3 rounded-lg bg-zinc-800/50 hover:bg-zinc-800 transition-colors cursor-pointer"
            >
              <div className="flex items-start justify-between mb-2">
                <div>
                  <h4 className="text-sm font-medium text-zinc-100">{detection.file}</h4>
                  <div className="flex items-center gap-2 mt-1">
                    <span className={`text-xs px-2 py-1 rounded-full capitalize ${getSeverityColor(detection.severity)}`}>
                      {detection.severity}
                    </span>
                    <span className="text-xs text-zinc-500">{detection.type}</span>
                  </div>
                </div>
                <span className={`text-xs px-2 py-1 rounded-full capitalize ${
                  detection.status === 'fixed' ? 'bg-emerald-500/10 text-emerald-400' :
                  detection.status === 'pending' ? 'bg-amber-500/10 text-amber-400' :
                  'bg-zinc-700 text-zinc-400'
                }`}>
                  {detection.status}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-red-500 hover:bg-red-600 text-white font-medium transition-colors">
          Run Full Scan
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Fix All
        </button>
      </div>
    </div>
  );
}
