'use client';

import { BookOpen, Database, Tag } from 'lucide-react';

interface SemanticMemoryPanelProps {
  totalPatterns?: number;
  avgConfidence?: number;
  categories?: Array<{ name: string; count: number }>;
  topPatterns?: Array<{ name: string; confidence: number; applications: number }>;
}

export function SemanticMemoryPanel({
  totalPatterns = 48,
  avgConfidence = 0.92,
  categories = [
    { name: 'Flutter', count: 12 },
    { name: 'Python', count: 8 },
    { name: 'Next.js', count: 6 },
    { name: 'Architecture', count: 10 },
  ],
  topPatterns = [
    { name: 'fastapi-templates', confidence: 0.98, applications: 24 },
    { name: 'nextjs-app-router', confidence: 0.95, applications: 18 },
    { name: 'tailwind-design', confidence: 0.94, applications: 15 },
  ],
}: SemanticMemoryPanelProps) {
  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-blue-500/10">
            <BookOpen className="text-blue-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Semantic Memory
            </h3>
            <p className="text-xs text-zinc-500">
              Reusable patterns & rules
            </p>
          </div>
        </div>
        <div className="px-3 py-1 rounded-full text-xs font-medium bg-blue-500/10 text-blue-400 border border-blue-500/20">
          {Math.round(avgConfidence * 100)}% Avg Confidence
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <Tag className="text-zinc-400" size={14} />
            <span className="text-sm text-zinc-400">Total Patterns</span>
          </div>
          <div className="text-2xl font-bold text-zinc-100">{totalPatterns}</div>
        </div>

        <div className="p-4 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <Database className="text-zinc-400" size={14} />
            <span className="text-sm text-zinc-400">Categories</span>
          </div>
          <div className="text-2xl font-bold text-zinc-100">{categories.length}</div>
        </div>
      </div>

      {/* Categories */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Categories</div>
        <div className="grid grid-cols-2 gap-2">
          {categories.map((cat, index) => (
            <div key={index} className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between">
              <span className="text-sm text-zinc-300">{cat.name}</span>
              <span className="text-xs font-medium text-blue-400">{cat.count}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Top Patterns */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Top Patterns</div>
        <div className="space-y-2">
          {topPatterns.map((pattern, index) => (
            <div key={index} className="p-3 rounded-lg bg-zinc-800/50">
              <div className="flex items-center justify-between mb-2">
                <h4 className="text-sm font-medium text-zinc-100">{pattern.name}</h4>
                <span className="text-xs text-blue-400 font-medium">{Math.round(pattern.confidence * 100)}%</span>
              </div>
              <div className="flex items-center gap-4 text-xs text-zinc-500">
                <span>Confidence: {Math.round(pattern.confidence * 100)}%</span>
                <span>Applications: {pattern.applications}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-blue-500 hover:bg-blue-600 text-white font-medium transition-colors">
          View All Patterns
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Add Pattern
        </button>
      </div>
    </div>
  );
}
