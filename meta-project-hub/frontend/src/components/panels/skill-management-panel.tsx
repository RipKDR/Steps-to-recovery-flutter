'use client';

import { Puzzle, Download, Upload, RefreshCw } from 'lucide-react';

interface SkillManagementPanelProps {
  totalSkills?: number;
  installed?: number;
  available?: number;
  outdated?: number;
  recentSkills?: Array<{
    name: string;
    installs: string;
    source: string;
  }>;
}

export function SkillManagementPanel({
  totalSkills = 147,
  installed = 11,
  available = 136,
  outdated = 2,
  recentSkills = [
    { name: 'nextjs-app-router-patterns', installs: '10.7K', source: 'wshobson/agents' },
    { name: 'tailwind-design-system', installs: '25.9K', source: 'wshobson/agents' },
    { name: 'fastapi-templates', installs: '9.6K', source: 'wshobson/agents' },
    { name: 'shadcn-ui', installs: '1.2K', source: 'jezweb/claude-skills' },
  ],
}: SkillManagementPanelProps) {
  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-pink-500/10">
            <Puzzle className="text-pink-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Skill Management
            </h3>
            <p className="text-xs text-zinc-500">
              {installed} installed / {totalSkills} available
            </p>
          </div>
        </div>
        <button className="p-2 rounded-lg hover:bg-zinc-800 transition-colors">
          <RefreshCw className="text-zinc-400" size={18} />
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-3 rounded-lg bg-emerald-500/10 border border-emerald-500/20">
          <div className="text-xs text-emerald-400 mb-1">Installed</div>
          <div className="text-xl font-bold text-emerald-400">{installed}</div>
        </div>

        <div className="p-3 rounded-lg bg-blue-500/10 border border-blue-500/20">
          <div className="text-xs text-blue-400 mb-1">Available</div>
          <div className="text-xl font-bold text-blue-400">{available}</div>
        </div>

        <div className="p-3 rounded-lg bg-amber-500/10 border border-amber-500/20">
          <div className="text-xs text-amber-400 mb-1">Outdated</div>
          <div className="text-xl font-bold text-amber-400">{outdated}</div>
        </div>
      </div>

      {/* Popular Skills */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Popular Skills</div>
        <div className="space-y-2">
          {recentSkills.map((skill, index) => (
            <div
              key={index}
              className="p-3 rounded-lg bg-zinc-800/50 hover:bg-zinc-800 transition-colors cursor-pointer"
            >
              <div className="flex items-start justify-between mb-2">
                <div>
                  <h4 className="text-sm font-medium text-zinc-100">{skill.name}</h4>
                  <p className="text-xs text-zinc-500 mt-1">{skill.source}</p>
                </div>
                <div className="flex items-center gap-1 text-xs text-purple-400">
                  <Download size={12} />
                  <span>{skill.installs}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-pink-500 hover:bg-pink-600 text-white font-medium transition-colors flex items-center justify-center gap-2">
          <Download size={18} />
          Install Skill
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          Manage
        </button>
      </div>
    </div>
  );
}
