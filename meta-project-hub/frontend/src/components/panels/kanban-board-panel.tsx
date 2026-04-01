'use client';

import { KanbanSquare, Plus, MoreHorizontal } from 'lucide-react';

interface KanbanBoardPanelProps {
  columns?: Array<{
    id: string;
    name: string;
    count: number;
    color: string;
  }>;
  totalTasks?: number;
}

export function KanbanBoardPanel({
  columns = [
    { id: 'inbox', name: 'Inbox', count: 5, color: 'bg-zinc-500' },
    { id: 'assigned', name: 'Assigned', count: 8, color: 'bg-blue-500' },
    { id: 'in_progress', name: 'In Progress', count: 6, color: 'bg-amber-500' },
    { id: 'review', name: 'Review', count: 3, color: 'bg-purple-500' },
    { id: 'quality', name: 'Quality', count: 2, color: 'bg-pink-500' },
    { id: 'done', name: 'Done', count: 12, color: 'bg-emerald-500' },
  ],
  totalTasks = 36,
}: KanbanBoardPanelProps) {
  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-indigo-500/10">
            <KanbanSquare className="text-indigo-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Kanban Board
            </h3>
            <p className="text-xs text-zinc-500">
              {totalTasks} total tasks
            </p>
          </div>
        </div>
        <button className="p-2 rounded-lg hover:bg-zinc-800 transition-colors">
          <MoreHorizontal className="text-zinc-400" size={20} />
        </button>
      </div>

      {/* Columns */}
      <div className="grid grid-cols-3 lg:grid-cols-6 gap-3 mb-6">
        {columns.map((column) => (
          <div
            key={column.id}
            className="p-4 rounded-lg bg-zinc-800/50 border border-zinc-700 hover:border-zinc-600 transition-colors cursor-pointer"
          >
            <div className="flex items-center justify-between mb-3">
              <div className={`w-2 h-2 rounded-full ${column.color}`} />
              <span className="text-lg font-bold text-zinc-100">{column.count}</span>
            </div>
            <div className="text-sm text-zinc-400">{column.name}</div>
          </div>
        ))}
      </div>

      {/* Progress Summary */}
      <div className="mb-6 p-4 rounded-lg bg-zinc-800/50">
        <div className="flex justify-between items-center mb-3">
          <span className="text-sm text-zinc-400">Sprint Progress</span>
          <span className="text-sm font-medium text-zinc-100">
            {Math.round(((columns.find(c => c.id === 'done')?.count || 0) / totalTasks) * 100)}%
          </span>
        </div>
        <div className="h-2 bg-zinc-700 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-indigo-500 to-purple-500 transition-all duration-500"
            style={{ width: `${((columns.find(c => c.id === 'done')?.count || 0) / totalTasks) * 100}%` }}
          />
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-indigo-500 hover:bg-indigo-600 text-white font-medium transition-colors flex items-center justify-center gap-2">
          <Plus size={18} />
          New Task
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Open Board
        </button>
      </div>
    </div>
  );
}
