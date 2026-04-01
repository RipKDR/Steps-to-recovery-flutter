'use client';

import { Lightbulb, ThumbsUp, Eye, Plus } from 'lucide-react';

interface FeatureRequestsPanelProps {
  totalRequests?: number;
  topVoted?: Array<{
    id: number;
    title: string;
    votes: number;
    status: 'planned' | 'under_review' | 'implemented';
  }>;
}

export function FeatureRequestsPanel({
  totalRequests = 67,
  topVoted = [
    { id: 1, title: 'Add daily reminders', votes: 142, status: 'planned' },
    { id: 2, title: 'Export progress as PDF', votes: 98, status: 'under_review' },
    { id: 3, title: 'Custom themes', votes: 76, status: 'implemented' },
    { id: 4, title: 'Widget for home screen', votes: 54, status: 'under_review' },
  ],
}: FeatureRequestsPanelProps) {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'planned':
        return 'text-blue-400 bg-blue-500/10';
      case 'under_review':
        return 'text-amber-400 bg-amber-500/10';
      case 'implemented':
        return 'text-emerald-400 bg-emerald-500/10';
    }
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-purple-500/10">
            <Lightbulb className="text-purple-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Feature Requests
            </h3>
            <p className="text-xs text-zinc-500">
              {totalRequests} requests from users
            </p>
          </div>
        </div>
        <button className="p-2 rounded-lg bg-purple-500 hover:bg-purple-600 text-white transition-colors">
          <Plus size={18} />
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <ThumbsUp className="text-zinc-400" size={14} />
            <span className="text-xs text-zinc-400">Total Votes</span>
          </div>
          <div className="text-xl font-bold text-zinc-100">2,847</div>
        </div>

        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <Eye className="text-zinc-400" size={14} />
            <span className="text-xs text-zinc-400">Under Review</span>
          </div>
          <div className="text-xl font-bold text-amber-400">24</div>
        </div>

        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="flex items-center gap-2 mb-2">
            <Lightbulb className="text-emerald-400" size={14} />
            <span className="text-xs text-zinc-400">Implemented</span>
          </div>
          <div className="text-xl font-bold text-emerald-400">18</div>
        </div>
      </div>

      {/* Top Voted */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Top Voted Requests</div>
        <div className="space-y-2">
          {topVoted.map((request) => (
            <div
              key={request.id}
              className="p-3 rounded-lg bg-zinc-800/50 hover:bg-zinc-800 transition-colors cursor-pointer"
            >
              <div className="flex items-start justify-between mb-2">
                <h4 className="text-sm font-medium text-zinc-100">{request.title}</h4>
                <span className={`text-xs px-2 py-1 rounded-full capitalize ${getStatusColor(request.status)}`}>
                  {request.status.replace('_', ' ')}
                </span>
              </div>
              <div className="flex items-center gap-4">
                <div className="flex items-center gap-1">
                  <ThumbsUp className="text-purple-500" size={12} />
                  <span className="text-xs font-medium text-purple-400">{request.votes} votes</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-purple-500 hover:bg-purple-600 text-white font-medium transition-colors">
          Submit Request
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View All
        </button>
      </div>
    </div>
  );
}
