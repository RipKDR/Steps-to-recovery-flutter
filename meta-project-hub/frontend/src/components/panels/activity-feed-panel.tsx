'use client';

import { Activity, Zap, MessageSquare, GitCommit } from 'lucide-react';

interface ActivityFeedPanelProps {
  activities?: Array<{
    id: string;
    type: 'agent' | 'security' | 'git' | 'build';
    message: string;
    time: string;
  }>;
}

export function ActivityFeedPanel({
  activities = [
    { id: '1', type: 'agent', message: 'Agent completed test generation', time: '2 min ago' },
    { id: '2', type: 'security', message: 'Security scan completed: 0 issues', time: '15 min ago' },
    { id: '3', type: 'git', message: 'Committed: feat: Add new panels', time: '1 hour ago' },
    { id: '4', type: 'build', message: 'Build succeeded in 2m 34s', time: '2 hours ago' },
    { id: '5', type: 'agent', message: 'Auto-fixed 3 code smells', time: '3 hours ago' },
  ],
}: ActivityFeedPanelProps) {
  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'agent':
        return <Zap className="text-blue-500" size={16} />;
      case 'security':
        return <Activity className="text-red-500" size={16} />;
      case 'git':
        return <GitCommit className="text-purple-500" size={16} />;
      case 'build':
        return <MessageSquare className="text-amber-500" size={16} />;
    }
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-cyan-500/10">
            <Activity className="text-cyan-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Activity Feed
            </h3>
            <p className="text-xs text-zinc-500">
              Real-time events
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
          <span className="text-xs text-emerald-400">Live</span>
        </div>
      </div>

      {/* Activity List */}
      <div className="space-y-3 mb-6 max-h-96 overflow-y-auto">
        {activities.map((activity) => (
          <div
            key={activity.id}
            className="p-3 rounded-lg bg-zinc-800/50 hover:bg-zinc-800 transition-colors cursor-pointer"
          >
            <div className="flex items-start gap-3">
              <div className="p-1.5 rounded bg-zinc-900 mt-0.5">
                {getTypeIcon(activity.type)}
              </div>
              <div className="flex-1">
                <p className="text-sm text-zinc-300">{activity.message}</p>
                <p className="text-xs text-zinc-500 mt-1">{activity.time}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-cyan-500 hover:bg-cyan-600 text-white font-medium transition-colors">
          View All
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Filter
        </button>
      </div>
    </div>
  );
}
