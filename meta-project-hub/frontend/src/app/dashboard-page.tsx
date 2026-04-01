'use client';

import { useState, useEffect } from 'react';
import { useDashboardStore } from '@/store/dashboard-store';
import { useWebSocket } from '@/hooks/use-websocket';
import { HeaderBar } from '@/components/layout/header-bar';
import { NavRail } from '@/components/layout/nav-rail';
import {
  CodeHealthPanel,
  TestCoveragePanel,
  BuildStatusPanel,
  DependenciesPanel,
  PerformancePanel,
  FeatureTrackerPanel,
  SecurityScanPanel,
  CodeSmellsPanel,
  AutoFixLogPanel,
  GitStatusPanel,
  CICDStatusPanel,
  ActivityFeedPanel,
  KanbanBoardPanel,
  SprintPlanningPanel,
  BacklogPanel,
  RoadmapPanel,
  BugTrackerPanel,
  FeatureRequestsPanel,
  AgentStatusPanel,
  SessionTrackingPanel,
  SkillManagementPanel,
  TaskQueuePanel,
  MemoryGraphPanel,
  AgentEvalsPanel,
  SemanticMemoryPanel,
  EpisodicMemoryPanel,
  WorkingMemoryPanel,
  PatternEvolutionPanel,
  PIIDetectionPanel,
  EncryptionStatusPanel,
  CompliancePanel,
  SecurityAuditPanel,
} from '@/components/panels';

export default function Dashboard() {
  const { metrics, loading, error, fetchMetrics } = useDashboardStore();
  const { connected } = useWebSocket();
  const [activeTab, setActiveTab] = useState<'all' | 'flutter' | 'agents' | 'tasks' | 'security'>('all');

  useEffect(() => {
    fetchMetrics();
  }, [fetchMetrics]);

  if (loading && !metrics) {
    return (
      <div className="min-h-screen bg-zinc-950 flex items-center justify-center">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-amber-500 border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-zinc-400">Loading Meta Project HUB...</p>
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
              <div className="text-red-500">⚠️</div>
              <p className="text-red-400">{error}</p>
            </div>
          )}

          {/* Tab Filter */}
          <div className="mb-6 flex gap-2 overflow-x-auto pb-2">
            <button
              onClick={() => setActiveTab('all')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors whitespace-nowrap ${
                activeTab === 'all'
                  ? 'bg-amber-500 text-zinc-950'
                  : 'bg-zinc-900 text-zinc-400 hover:text-zinc-100'
              }`}
            >
              All Panels ({32})
            </button>
            <button
              onClick={() => setActiveTab('flutter')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors whitespace-nowrap ${
                activeTab === 'flutter'
                  ? 'bg-cyan-500 text-zinc-950'
                  : 'bg-zinc-900 text-zinc-400 hover:text-zinc-100'
              }`}
            >
              Flutter Metrics (6)
            </button>
            <button
              onClick={() => setActiveTab('agents')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors whitespace-nowrap ${
                activeTab === 'agents'
                  ? 'bg-indigo-500 text-zinc-950'
                  : 'bg-zinc-900 text-zinc-400 hover:text-zinc-100'
              }`}
            >
              Agents (6)
            </button>
            <button
              onClick={() => setActiveTab('tasks')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors whitespace-nowrap ${
                activeTab === 'tasks'
                  ? 'bg-green-500 text-zinc-950'
                  : 'bg-zinc-900 text-zinc-400 hover:text-zinc-100'
              }`}
            >
              Tasks (6)
            </button>
            <button
              onClick={() => setActiveTab('security')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors whitespace-nowrap ${
                activeTab === 'security'
                  ? 'bg-red-500 text-zinc-950'
                  : 'bg-zinc-900 text-zinc-400 hover:text-zinc-100'
              }`}
            >
              Security (4)
            </button>
          </div>

          {/* Connection Status */}
          <div className="mb-6 text-center text-sm text-zinc-500">
            {connected ? (
              <span className="text-emerald-500">●</span>
            ) : (
              <span className="text-amber-500">●</span>
            )}{' '}
            {connected ? 'Connected to backend' : 'Disconnected - Using mock data'}
          </div>

          {/* Dashboard Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {/* Flutter Metrics */}
            {(activeTab === 'all' || activeTab === 'flutter') && (
              <>
                <CodeHealthPanel />
                <TestCoveragePanel />
                <BuildStatusPanel />
                <DependenciesPanel />
                <PerformancePanel />
                <FeatureTrackerPanel />
              </>
            )}

            {/* Meta-Systems */}
            {(activeTab === 'all' || activeTab === 'security') && (
              <>
                <SecurityScanPanel />
                <CodeSmellsPanel />
                <AutoFixLogPanel />
                <GitStatusPanel />
                <CICDStatusPanel />
                <ActivityFeedPanel />
              </>
            )}

            {/* Task Management */}
            {(activeTab === 'all' || activeTab === 'tasks') && (
              <>
                <KanbanBoardPanel />
                <SprintPlanningPanel />
                <BacklogPanel />
                <RoadmapPanel />
                <BugTrackerPanel />
                <FeatureRequestsPanel />
              </>
            )}

            {/* Agent Operations */}
            {(activeTab === 'all' || activeTab === 'agents') && (
              <>
                <AgentStatusPanel />
                <SessionTrackingPanel />
                <SkillManagementPanel />
                <TaskQueuePanel />
                <MemoryGraphPanel />
                <AgentEvalsPanel />
              </>
            )}

            {/* Memory & Learning */}
            {activeTab === 'all' && (
              <>
                <SemanticMemoryPanel />
                <EpisodicMemoryPanel />
                <WorkingMemoryPanel />
                <PatternEvolutionPanel />
              </>
            )}

            {/* Security & Compliance */}
            {(activeTab === 'all' || activeTab === 'security') && (
              <>
                <PIIDetectionPanel />
                <EncryptionStatusPanel />
                <CompliancePanel />
                <SecurityAuditPanel />
              </>
            )}
          </div>

          {/* Footer */}
          <div className="mt-12 text-center text-xs text-zinc-600">
            <p>Meta Project HUB v1.0.0 • 32 Panels • Mission Control Inspired</p>
            <p className="mt-1">Built for Steps to Recovery Flutter App</p>
          </div>
        </main>
      </div>
    </div>
  );
}
