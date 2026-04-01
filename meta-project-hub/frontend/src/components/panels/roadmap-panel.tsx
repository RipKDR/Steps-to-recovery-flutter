'use client';

import { Flag, Calendar, Milestone, TrendingUp } from 'lucide-react';

interface RoadmapPanelProps {
  milestones?: Array<{
    id: number;
    title: string;
    date: string;
    status: 'completed' | 'in_progress' | 'upcoming';
    progress?: number;
  }>;
  completionRate?: number;
}

export function RoadmapPanel({
  milestones = [
    { id: 1, title: 'Beta Launch', date: '2026-03-15', status: 'completed', progress: 100 },
    { id: 2, title: 'AI Companion', date: '2026-04-30', status: 'in_progress', progress: 65 },
    { id: 3, title: 'Sponsor Integration', date: '2026-05-15', status: 'in_progress', progress: 40 },
    { id: 4, title: 'Public Release', date: '2026-06-01', status: 'upcoming', progress: 0 },
  ],
  completionRate = 72,
}: RoadmapPanelProps) {
  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-orange-500/10">
            <Flag className="text-orange-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Recovery Roadmap
            </h3>
            <p className="text-xs text-zinc-500">
              Product milestones
            </p>
          </div>
        </div>
        <div className="px-3 py-1 rounded-full text-xs font-medium bg-orange-500/10 text-orange-400 border border-orange-500/20">
          {completionRate}% Complete
        </div>
      </div>

      {/* Overall Progress */}
      <div className="mb-6">
        <div className="flex justify-between text-sm mb-2">
          <span className="text-zinc-400">Roadmap Progress</span>
          <span className="text-zinc-100 font-medium">{completionRate}%</span>
        </div>
        <div className="h-3 bg-zinc-800 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-orange-500 to-amber-500 transition-all duration-500"
            style={{ width: `${completionRate}%` }}
          />
        </div>
      </div>

      {/* Milestones */}
      <div className="space-y-4 mb-6">
        {milestones.map((milestone) => (
          <div
            key={milestone.id}
            className="p-4 rounded-lg bg-zinc-800/50 border border-zinc-700"
          >
            <div className="flex items-start justify-between mb-3">
              <div className="flex items-center gap-3">
                <div className={`p-2 rounded-lg ${
                  milestone.status === 'completed' ? 'bg-emerald-500/10' :
                  milestone.status === 'in_progress' ? 'bg-blue-500/10' :
                  'bg-zinc-700'
                }`}>
                  <Milestone className={`size-4 ${
                    milestone.status === 'completed' ? 'text-emerald-500' :
                    milestone.status === 'in_progress' ? 'text-blue-500' :
                    'text-zinc-400'
                  }`} />
                </div>
                <div>
                  <h4 className="text-sm font-semibold text-zinc-100">{milestone.title}</h4>
                  <div className="flex items-center gap-2 mt-1">
                    <Calendar className="text-zinc-500" size={12} />
                    <span className="text-xs text-zinc-500">{new Date(milestone.date).toLocaleDateString()}</span>
                  </div>
                </div>
              </div>
              <span className={`text-xs font-medium px-2 py-1 rounded-full ${
                milestone.status === 'completed' ? 'bg-emerald-500/10 text-emerald-400' :
                milestone.status === 'in_progress' ? 'bg-blue-500/10 text-blue-400' :
                'bg-zinc-700 text-zinc-400'
              }`}>
                {milestone.status === 'completed' ? 'Done' :
                 milestone.status === 'in_progress' ? 'In Progress' :
                 'Upcoming'}
              </span>
            </div>
            
            {milestone.status === 'in_progress' && milestone.progress! > 0 && (
              <div>
                <div className="h-1.5 bg-zinc-700 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-blue-500 transition-all duration-500"
                    style={{ width: `${milestone.progress}%` }}
                  />
                </div>
                <div className="text-xs text-zinc-500 mt-1">{milestone.progress}% complete</div>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-orange-500 hover:bg-orange-600 text-white font-medium transition-colors">
          View Timeline
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Edit Milestones
        </button>
      </div>
    </div>
  );
}
