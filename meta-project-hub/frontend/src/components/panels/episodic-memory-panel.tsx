'use client';

import { Calendar, Clock, Bookmark } from 'lucide-react';

interface EpisodicMemoryPanelProps {
  totalEpisodes?: number;
  thisWeek?: number;
  avgRating?: number;
  recentEpisodes?: Array<{
    date: string;
    skill: string;
    outcome: 'success' | 'partial' | 'failure';
    rating: number;
  }>;
}

export function EpisodicMemoryPanel({
  totalEpisodes = 89,
  thisWeek = 12,
  avgRating = 7.8,
  recentEpisodes = [
    { date: '2026-04-02', skill: 'flutter-architect', outcome: 'success', rating: 9 },
    { date: '2026-04-01', skill: 'security-specialist', outcome: 'success', rating: 8 },
    { date: '2026-03-31', skill: 'service-architect', outcome: 'partial', rating: 6 },
    { date: '2026-03-30', skill: 'meta-systems-hub', outcome: 'success', rating: 9 },
  ],
}: EpisodicMemoryPanelProps) {
  const getOutcomeColor = (outcome: string) => {
    switch (outcome) {
      case 'success':
        return 'text-emerald-400 bg-emerald-500/10';
      case 'partial':
        return 'text-amber-400 bg-amber-500/10';
      case 'failure':
        return 'text-red-400 bg-red-500/10';
    }
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-purple-500/10">
            <Calendar className="text-purple-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Episodic Memory
            </h3>
            <p className="text-xs text-zinc-500">
              Session experiences
            </p>
          </div>
        </div>
        <div className="px-3 py-1 rounded-full text-xs font-medium bg-purple-500/10 text-purple-400 border border-purple-500/20">
          {thisWeek} this week
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="text-xs text-zinc-400 mb-1">Total</div>
          <div className="text-xl font-bold text-zinc-100">{totalEpisodes}</div>
        </div>

        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="text-xs text-zinc-400 mb-1">This Week</div>
          <div className="text-xl font-bold text-purple-400">{thisWeek}</div>
        </div>

        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="text-xs text-zinc-400 mb-1">Avg Rating</div>
          <div className="text-xl font-bold text-amber-400">{avgRating}</div>
        </div>
      </div>

      {/* Recent Episodes */}
      <div className="space-y-2 mb-6">
        <div className="text-sm text-zinc-400 mb-3">Recent Sessions</div>
        {recentEpisodes.map((episode, index) => (
          <div
            key={index}
            className="p-3 rounded-lg bg-zinc-800/50 hover:bg-zinc-800 transition-colors cursor-pointer"
          >
            <div className="flex items-start justify-between mb-2">
              <div className="flex items-center gap-2">
                <Bookmark className="text-zinc-500" size={14} />
                <span className="text-sm font-medium text-zinc-100">{episode.skill}</span>
              </div>
              <span className={`text-xs px-2 py-1 rounded-full capitalize ${getOutcomeColor(episode.outcome)}`}>
                {episode.outcome}
              </span>
            </div>
            <div className="flex items-center justify-between text-xs text-zinc-500">
              <div className="flex items-center gap-1">
                <Clock size={10} />
                <span>{new Date(episode.date).toLocaleDateString()}</span>
              </div>
              <div className="flex items-center gap-1 text-amber-400">
                <span>★</span>
                <span>{episode.rating}/10</span>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-purple-500 hover:bg-purple-600 text-white font-medium transition-colors">
          View Timeline
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Export
        </button>
      </div>
    </div>
  );
}
