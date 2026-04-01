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
import { FadeIn, SlideIn, gridStagger, gridItem } from '@/lib/animations';
import { motion } from 'framer-motion';

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
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.5 }}
          className="text-center"
        >
          <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
            className="w-12 h-12 border-4 border-amber-500 border-t-transparent rounded-full mb-4"
          />
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="text-zinc-400"
          >
            Loading Meta Project HUB...
          </motion.p>
        </motion.div>
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
            <motion.div
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              className="mb-6 p-4 rounded-lg bg-red-500/10 border border-red-500/20 flex items-center gap-3"
            >
              <motion.span
                animate={{ rotate: [0, 10, -10, 0] }}
                transition={{ duration: 0.5, repeat: 3 }}
                className="text-red-500"
              >
                ⚠️
              </motion.span>
              <p className="text-red-400">{error}</p>
            </motion.div>
          )}

          {/* Tab Filter */}
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="mb-6 flex gap-2 overflow-x-auto pb-2"
          >
            {[
              { id: 'all', label: 'All Panels', count: 32, color: 'amber' },
              { id: 'flutter', label: 'Flutter', count: 6, color: 'cyan' },
              { id: 'agents', label: 'Agents', count: 6, color: 'indigo' },
              { id: 'tasks', label: 'Tasks', count: 6, color: 'green' },
              { id: 'security', label: 'Security', count: 4, color: 'red' },
            ].map((tab, index) => (
              <motion.button
                key={tab.id}
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.3 + index * 0.05 }}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setActiveTab(tab.id as typeof activeTab)}
                className={`px-4 py-2 rounded-lg font-medium transition-colors whitespace-nowrap ${
                  activeTab === tab.id
                    ? `bg-${tab.color}-500 text-zinc-950`
                    : 'bg-zinc-900 text-zinc-400 hover:text-zinc-100'
                }`}
              >
                {tab.label} ({tab.count})
              </motion.button>
            ))}
          </motion.div>

          {/* Connection Status */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5 }}
            className="mb-6 text-center text-sm text-zinc-500"
          >
            <motion.span
              animate={{ scale: [1, 1.2, 1] }}
              transition={{ duration: 2, repeat: Infinity }}
              className={connected ? 'text-emerald-500' : 'text-amber-500'}
            >
              ●
            </motion.span>{' '}
            {connected ? 'Connected to backend' : 'Disconnected - Using mock data'}
          </motion.div>

          {/* Dashboard Grid with Stagger Animation */}
          <motion.div
            variants={gridStagger}
            initial="hidden"
            animate="visible"
            className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
          >
            {/* Flutter Metrics */}
            {(activeTab === 'all' || activeTab === 'flutter') && (
              <>
                <motion.div variants={gridItem} className="col-span-1">
                  <CodeHealthPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <TestCoveragePanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <BuildStatusPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <DependenciesPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <PerformancePanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <FeatureTrackerPanel />
                </motion.div>
              </>
            )}

            {/* Meta-Systems */}
            {(activeTab === 'all' || activeTab === 'security') && (
              <>
                <motion.div variants={gridItem} className="col-span-1">
                  <SecurityScanPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <CodeSmellsPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <AutoFixLogPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <GitStatusPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <CICDStatusPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <ActivityFeedPanel />
                </motion.div>
              </>
            )}

            {/* Task Management */}
            {(activeTab === 'all' || activeTab === 'tasks') && (
              <>
                <motion.div variants={gridItem} className="col-span-1">
                  <KanbanBoardPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <SprintPlanningPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <BacklogPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <RoadmapPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <BugTrackerPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <FeatureRequestsPanel />
                </motion.div>
              </>
            )}

            {/* Agent Operations */}
            {(activeTab === 'all' || activeTab === 'agents') && (
              <>
                <motion.div variants={gridItem} className="col-span-1">
                  <AgentStatusPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <SessionTrackingPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <SkillManagementPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <TaskQueuePanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <MemoryGraphPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <AgentEvalsPanel />
                </motion.div>
              </>
            )}

            {/* Memory & Learning */}
            {activeTab === 'all' && (
              <>
                <motion.div variants={gridItem} className="col-span-1">
                  <SemanticMemoryPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <EpisodicMemoryPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <WorkingMemoryPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <PatternEvolutionPanel />
                </motion.div>
              </>
            )}

            {/* Security & Compliance */}
            {(activeTab === 'all' || activeTab === 'security') && (
              <>
                <motion.div variants={gridItem} className="col-span-1">
                  <PIIDetectionPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <EncryptionStatusPanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <CompliancePanel />
                </motion.div>
                <motion.div variants={gridItem} className="col-span-1">
                  <SecurityAuditPanel />
                </motion.div>
              </>
            )}
          </motion.div>

          {/* Footer */}
          <motion.footer
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 1 }}
            className="mt-12 text-center text-xs text-zinc-600"
          >
            <motion.p
              animate={{ opacity: [0.6, 1, 0.6] }}
              transition={{ duration: 3, repeat: Infinity }}
            >
              Meta Project HUB v1.0.0 • 32 Panels • Mission Control Inspired
            </motion.p>
            <motion.p
              animate={{ opacity: [0.6, 1, 0.6] }}
              transition={{ duration: 3, repeat: Infinity, delay: 0.5 }}
              className="mt-1"
            >
              Built for Steps to Recovery Flutter App
            </motion.p>
          </motion.footer>
        </main>
      </div>
    </div>
  );
}
