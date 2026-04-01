'use client';

import { useEffect } from 'react';
import { useDashboardStore } from '@/store/dashboard-store';
import { useWebSocket } from '@/hooks/use-websocket';
import { HeaderBar } from '@/components/layout/header-bar';
import { NavRail } from '@/components/layout/nav-rail';
import {
  Cpu,
  Shield,
  FlaskConical,
  GitBranch,
  TrendingUp,
  AlertCircle,
} from 'lucide-react';

export default function Dashboard() {
  const { metrics, loading, error, fetchMetrics } = useDashboardStore();
  const { connected } = useWebSocket();

  useEffect(() => {
    fetchMetrics();
  }, [fetchMetrics]);

  if (loading && !metrics) {
    return (
      <div className="min-h-screen bg-zinc-950 flex items-center justify-center">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-amber-500 border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-zinc-400">Loading dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-zinc-950">
      <NavRail />
      
      <div className="ml-16">
        <HeaderBar />
        
        <main className="p-6">
          {/* Error State */}
          {error && (
            <div className="mb-6 p-4 rounded-lg bg-red-500/10 border border-red-500/20 flex items-center gap-3">
              <AlertCircle className="text-red-500" size={20} />
              <p className="text-red-400">{error}</p>
            </div>
          )}

          {/* Overview Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
            {/* Agents */}
            <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
              <div className="flex items-center justify-between mb-4">
                <Cpu className="text-blue-500" size={24} />
                <span className="text-xs text-zinc-500">Real-time</span>
              </div>
              <div className="text-3xl font-bold text-zinc-100 mb-1">
                {metrics?.agents.online ?? 0}
              </div>
              <div className="text-sm text-zinc-500">
                of {metrics?.agents.total ?? 0} agents online
              </div>
            </div>

            {/* Sessions */}
            <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
              <div className="flex items-center justify-between mb-4">
                <TrendingUp className="text-emerald-500" size={24} />
                <span className="text-xs text-zinc-500">Active</span>
              </div>
              <div className="text-3xl font-bold text-zinc-100 mb-1">
                {metrics?.sessions.active ?? 0}
              </div>
              <div className="text-sm text-zinc-500">active sessions</div>
            </div>

            {/* Security */}
            <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
              <div className="flex items-center justify-between mb-4">
                <Shield className="text-amber-500" size={24} />
                <span className="text-xs text-zinc-500">Trust Score</span>
              </div>
              <div className="text-3xl font-bold text-zinc-100 mb-1">
                {metrics?.security.trustScore ?? 0}
              </div>
              <div className="text-sm text-zinc-500">security rating</div>
            </div>

            {/* Tasks */}
            <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
              <div className="flex items-center justify-between mb-4">
                <GitBranch className="text-purple-500" size={24} />
                <span className="text-xs text-zinc-500">Pending</span>
              </div>
              <div className="text-3xl font-bold text-zinc-100 mb-1">
                {metrics?.tasks.pending ?? 0}
              </div>
              <div className="text-sm text-zinc-500">tasks pending</div>
            </div>
          </div>

          {/* Detailed Metrics */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
            {/* Flutter Metrics */}
            <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
              <div className="flex items-center gap-2 mb-4">
                <FlaskConical className="text-cyan-500" size={20} />
                <h3 className="text-lg font-semibold text-zinc-100">
                  Flutter App Health
                </h3>
              </div>
              
              <div className="space-y-4">
                <div>
                  <div className="flex justify-between text-sm mb-2">
                    <span className="text-zinc-400">Code Health</span>
                    <span className="text-zinc-100 font-medium">
                      {metrics?.flutter.codeHealth ?? 0}%
                    </span>
                  </div>
                  <div className="h-2 bg-zinc-800 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-gradient-to-r from-cyan-500 to-blue-500 transition-all duration-500"
                      style={{
                        width: `${metrics?.flutter.codeHealth ?? 0}%`,
                      }}
                    />
                  </div>
                </div>

                <div>
                  <div className="flex justify-between text-sm mb-2">
                    <span className="text-zinc-400">Test Coverage</span>
                    <span className="text-zinc-100 font-medium">
                      {metrics?.flutter.testCoverage ?? 0}%
                    </span>
                  </div>
                  <div className="h-2 bg-zinc-800 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-gradient-to-r from-emerald-500 to-green-500 transition-all duration-500"
                      style={{
                        width: `${metrics?.flutter.testCoverage ?? 0}%`,
                      }}
                    />
                  </div>
                </div>

                <div className="pt-2">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-zinc-400">Build Status</span>
                    <span
                      className={`px-2 py-1 rounded text-xs font-medium ${
                        metrics?.flutter.buildStatus === 'success'
                          ? 'bg-emerald-500/10 text-emerald-400'
                          : 'bg-red-500/10 text-red-400'
                      }`}
                    >
                      {metrics?.flutter.buildStatus ?? 'Unknown'}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            {/* Meta-Systems Status */}
            <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
              <div className="flex items-center gap-2 mb-4">
                <Cpu className="text-purple-500" size={20} />
                <h3 className="text-lg font-semibold text-zinc-100">
                  Meta-Systems Hub
                </h3>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="p-4 rounded-lg bg-zinc-800/50">
                  <div className="text-2xl font-bold text-red-400 mb-1">
                    {metrics?.metaSystems.issuesFound ?? 0}
                  </div>
                  <div className="text-xs text-zinc-500">Issues Found</div>
                </div>

                <div className="p-4 rounded-lg bg-zinc-800/50">
                  <div className="text-2xl font-bold text-emerald-400 mb-1">
                    {metrics?.metaSystems.issuesFixed ?? 0}
                  </div>
                  <div className="text-xs text-zinc-500">Issues Fixed</div>
                </div>

                <div className="p-4 rounded-lg bg-zinc-800/50 col-span-2">
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-zinc-400">
                      Auto-Fix Success Rate
                    </span>
                    <span className="text-lg font-bold text-zinc-100">
                      {metrics?.metaSystems.issuesFound
                        ? Math.round(
                            (metrics.metaSystems.issuesFixed /
                              metrics.metaSystems.issuesFound) *
                              100
                          )
                        : 0}
                      %
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Connection Status */}
          <div className="text-center text-sm text-zinc-500">
            {connected ? (
              <span className="text-emerald-500">●</span>
            ) : (
              <span className="text-red-500">●</span>
            )}{' '}
            {connected ? 'Connected to backend' : 'Disconnected - Retrying...'}
          </div>
        </main>
      </div>
    </div>
  );
}
