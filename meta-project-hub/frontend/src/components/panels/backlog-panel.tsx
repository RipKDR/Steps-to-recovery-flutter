'use client';

import { List, Plus, Filter } from 'lucide-react';

interface BacklogPanelProps {
  totalItems?: number;
  priority?: {
    high: number;
    medium: number;
    low: number;
  };
  estimatedHours?: number;
}

export function BacklogPanel({
  totalItems = 48,
  priority = { high: 12, medium: 24, low: 12 },
  estimatedHours = 156,
}: BacklogPanelProps) {
  const sampleItems = [
    { id: 1, title: 'Add biometric authentication', priority: 'high', points: 8 },
    { id: 2, title: 'Implement sponsor chat encryption', priority: 'high', points: 13 },
    { id: 3, title: 'Create recovery milestone badges', priority: 'medium', points: 5 },
    { id: 4, title: 'Add dark mode toggle', priority: 'low', points: 3 },
  ];

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-slate-500/10">
            <List className="text-slate-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Product Backlog
            </h3>
            <p className="text-xs text-zinc-500">
              {totalItems} items • {estimatedHours}h estimated
            </p>
          </div>
        </div>
        <div className="flex gap-2">
          <button className="p-2 rounded-lg hover:bg-zinc-800 transition-colors">
            <Filter className="text-zinc-400" size={18} />
          </button>
          <button className="p-2 rounded-lg bg-slate-500 hover:bg-slate-600 text-white transition-colors">
            <Plus size={18} />
          </button>
        </div>
      </div>

      {/* Priority Breakdown */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-4 rounded-lg bg-red-500/10 border border-red-500/20">
          <div className="text-sm text-red-400 mb-1">High Priority</div>
          <div className="text-2xl font-bold text-red-400">{priority.high}</div>
        </div>

        <div className="p-4 rounded-lg bg-amber-500/10 border border-amber-500/20">
          <div className="text-sm text-amber-400 mb-1">Medium</div>
          <div className="text-2xl font-bold text-amber-400">{priority.medium}</div>
        </div>

        <div className="p-4 rounded-lg bg-blue-500/10 border border-blue-500/20">
          <div className="text-sm text-blue-400 mb-1">Low</div>
          <div className="text-2xl font-bold text-blue-400">{priority.low}</div>
        </div>
      </div>

      {/* Top Items */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Top Priority Items</div>
        <div className="space-y-2">
          {sampleItems.map((item) => (
            <div
              key={item.id}
              className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between hover:bg-zinc-800 transition-colors cursor-pointer"
            >
              <div className="flex items-center gap-3">
                <div className={`w-2 h-2 rounded-full ${
                  item.priority === 'high' ? 'bg-red-500' :
                  item.priority === 'medium' ? 'bg-amber-500' :
                  'bg-blue-500'
                }`} />
                <span className="text-sm text-zinc-300">{item.title}</span>
              </div>
              <span className="text-xs font-medium text-zinc-500">{item.points} pts</span>
            </div>
          ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-slate-500 hover:bg-slate-600 text-white font-medium transition-colors">
          View All
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Prioritize
        </button>
      </div>
    </div>
  );
}
