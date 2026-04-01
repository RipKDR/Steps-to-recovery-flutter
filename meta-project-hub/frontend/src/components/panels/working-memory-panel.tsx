'use client';

import { Brain, Cpu, Clock, Zap } from 'lucide-react';

interface WorkingMemoryPanelProps {
  activeSession?: {
    id: string;
    started: string;
    duration: string;
    contextSize: number;
  };
  activeContexts?: number;
  shortTermItems?: number;
  attentionFocus?: string;
}

export function WorkingMemoryPanel({
  activeSession = {
    id: 'session-2026-04-02-001',
    started: '2026-04-02T08:00:00',
    duration: '2h 34m',
    contextSize: 128000,
  },
  activeContexts = 3,
  shortTermItems = 7,
  attentionFocus = 'Building 32 panels for Meta Project HUB',
}: WorkingMemoryPanelProps) {
  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-green-500/10">
            <Brain className="text-green-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Working Memory
            </h3>
            <p className="text-xs text-zinc-500">
              Current session context
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
          <span className="text-xs text-emerald-400">Active</span>
        </div>
      </div>

      {/* Session Info */}
      <div className="mb-6 p-4 rounded-lg bg-zinc-800/50 border border-zinc-700">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <Cpu className="text-zinc-400" size={16} />
            <span className="text-sm text-zinc-400">Session ID</span>
          </div>
          <span className="text-sm font-mono text-zinc-100">{activeSession.id}</span>
        </div>
        <div className="grid grid-cols-3 gap-4">
          <div>
            <div className="text-xs text-zinc-500 mb-1">Started</div>
            <div className="text-sm font-medium text-zinc-100">
              {new Date(activeSession.started).toLocaleTimeString()}
            </div>
          </div>
          <div>
            <div className="text-xs text-zinc-500 mb-1">Duration</div>
            <div className="text-sm font-medium text-zinc-100">{activeSession.duration}</div>
          </div>
          <div>
            <div className="text-xs text-zinc-500 mb-1">Context Size</div>
            <div className="text-sm font-medium text-zinc-100">
              {Math.round(activeSession.contextSize / 1000)}K tokens
            </div>
          </div>
        </div>
      </div>

      {/* Current State */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <Clock className="text-zinc-400" size={14} />
            <span className="text-sm text-zinc-400">Active Contexts</span>
          </div>
          <div className="text-2xl font-bold text-blue-400">{activeContexts}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <Zap className="text-zinc-400" size={14} />
            <span className="text-sm text-zinc-400">Short-term Items</span>
          </div>
          <div className="text-2xl font-bold text-amber-400">{shortTermItems}</div>
        </div>
      </div>

      {/* Attention Focus */}
      <div className="mb-6 p-4 rounded-lg bg-emerald-500/10 border border-emerald-500/20">
        <div className="text-xs text-emerald-400 mb-2">Current Focus</div>
        <p className="text-sm text-zinc-100">{attentionFocus}</p>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-green-500 hover:bg-green-600 text-white font-medium transition-colors">
          View Context
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Save Session
        </button>
      </div>
    </div>
  );
}
