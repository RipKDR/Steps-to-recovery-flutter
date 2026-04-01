'use client';

import { Package, CheckCircle, XCircle, Clock } from 'lucide-react';

interface BuildStatusPanelProps {
  status?: 'success' | 'failure' | 'building';
  platform?: string;
  duration?: string;
  builtAt?: string;
}

export function BuildStatusPanel({
  status = 'success',
  platform = 'android',
  duration = '2m 34s',
  builtAt = new Date().toISOString(),
}: BuildStatusPanelProps) {
  const getStatusIcon = () => {
    switch (status) {
      case 'success':
        return <CheckCircle className="text-emerald-500" size={24} />;
      case 'failure':
        return <XCircle className="text-red-500" size={24} />;
      case 'building':
        return <Clock className="text-blue-500 animate-pulse" size={24} />;
    }
  };

  const getStatusBg = () => {
    switch (status) {
      case 'success':
        return 'bg-emerald-500/10 border-emerald-500/20';
      case 'failure':
        return 'bg-red-500/10 border-red-500/20';
      case 'building':
        return 'bg-blue-500/10 border-blue-500/20';
    }
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-amber-500/10">
            <Package className="text-amber-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Build Status
            </h3>
            <p className="text-xs text-zinc-500 capitalize">
              {platform} • {new Date(builtAt).toLocaleDateString()}
            </p>
          </div>
        </div>
        <div className={`p-3 rounded-lg ${getStatusBg()}`}>
          {getStatusIcon()}
        </div>
      </div>

      {/* Status */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-2">Current Status</div>
        <div className={`text-2xl font-bold capitalize ${
          status === 'success' ? 'text-emerald-400' :
          status === 'failure' ? 'text-red-400' :
          'text-blue-400'
        }`}>
          {status === 'building' ? 'Building...' : status}
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="text-sm text-zinc-400 mb-1">Duration</div>
          <div className="text-xl font-bold text-zinc-100">{duration}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="text-sm text-zinc-400 mb-1">Platform</div>
          <div className="text-xl font-bold text-zinc-100 capitalize">
            {platform}
          </div>
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button
          disabled={status === 'building'}
          className="flex-1 px-4 py-2 rounded-lg bg-amber-500 hover:bg-amber-600 disabled:opacity-50 disabled:cursor-not-allowed text-zinc-950 font-medium transition-colors"
        >
          Build APK
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          History
        </button>
      </div>
    </div>
  );
}
