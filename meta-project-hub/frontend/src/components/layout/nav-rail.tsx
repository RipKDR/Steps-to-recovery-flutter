'use client';

import { usePathname } from 'next/navigation';
import Link from 'next/link';
import {
  LayoutDashboard,
  Cpu,
  FlaskConical,
  GitBranch,
  CheckSquare,
  Brain,
  Shield,
  Settings,
} from 'lucide-react';

const navItems = [
  { icon: LayoutDashboard, label: 'Dashboard', href: '/' },
  { icon: Cpu, label: 'Agents', href: '/agents' },
  { icon: FlaskConical, label: 'Flutter', href: '/flutter' },
  { icon: GitBranch, label: 'Meta-Systems', href: '/meta-systems' },
  { icon: CheckSquare, label: 'Tasks', href: '/tasks' },
  { icon: Brain, label: 'Memory', href: '/memory' },
  { icon: Shield, label: 'Security', href: '/security' },
  { icon: Settings, label: 'Settings', href: '/settings' },
];

export function NavRail() {
  const pathname = usePathname();

  return (
    <nav className="fixed left-0 top-0 h-full w-16 bg-zinc-950 border-r border-zinc-800 flex flex-col items-center py-4 z-50">
      {/* Logo */}
      <div className="mb-8">
        <div className="w-10 h-10 rounded-lg bg-amber-500 flex items-center justify-center">
          <span className="text-zinc-950 font-bold text-lg">M</span>
        </div>
      </div>

      {/* Navigation */}
      <div className="flex-1 flex flex-col gap-2">
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          const Icon = item.icon;

          return (
            <Link
              key={item.href}
              href={item.href}
              className={`
                w-12 h-12 rounded-lg flex items-center justify-center
                transition-all duration-200
                ${
                  isActive
                    ? 'bg-amber-500 text-zinc-950'
                    : 'text-zinc-400 hover:text-zinc-100 hover:bg-zinc-900'
                }
              `}
              title={item.label}
            >
              <Icon size={20} />
            </Link>
          );
        })}
      </div>

      {/* User */}
      <div className="mt-auto">
        <div className="w-10 h-10 rounded-full bg-zinc-800 flex items-center justify-center">
          <span className="text-zinc-400 text-sm font-medium">H</span>
        </div>
      </div>
    </nav>
  );
}
