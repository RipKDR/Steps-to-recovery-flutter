/**
 * Meta Project HUB Store
 * Centralized state management using Zustand
 */

import { create } from 'zustand';

// Types
export interface Metrics {
  agents: { online: number; total: number; busy: number; idle: number };
  sessions: { active: number };
  tasks: { pending: number; inProgress: number; review: number; done: number };
  flutter: { codeHealth: number; testCoverage: number; buildStatus: string };
  security: { trustScore: number; piiIssues: number };
  metaSystems: { issuesFound: number; issuesFixed: number };
}

export interface Activity {
  id: string;
  type: string;
  message: string;
  timestamp: string;
}

interface DashboardState {
  // Data
  metrics: Metrics | null;
  activities: Activity[];
  loading: boolean;
  error: string | null;
  websocketConnected: boolean;

  // Actions
  setMetrics: (metrics: Metrics) => void;
  addActivity: (activity: Activity) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  setWebSocketConnected: (connected: boolean) => void;
  fetchMetrics: () => Promise<void>;
  reset: () => void;
}

const initialState = {
  metrics: null,
  activities: [],
  loading: false,
  error: null,
  websocketConnected: false,
};

export const useDashboardStore = create<DashboardState>((set, get) => ({
  ...initialState,

  setMetrics: (metrics: Metrics) => set({ metrics, error: null }),

  addActivity: (activity: Activity) =>
    set((state) => ({
      activities: [activity, ...state.activities].slice(0, 50), // Keep last 50
    })),

  setLoading: (loading: boolean) => set({ loading }),

  setError: (error: string | null) => set({ error, loading: false }),

  setWebSocketConnected: (connected: boolean) =>
    set({ websocketConnected: connected }),

  fetchMetrics: async () => {
    set({ loading: true, error: null });
    try {
      const response = await fetch('http://localhost:8000/v1/dashboard/overview');
      if (!response.ok) throw new Error('Failed to fetch metrics');
      const data = await response.json();
      set({ metrics: data.data, loading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Unknown error',
        loading: false,
      });
    }
  },

  reset: () => set(initialState),
}));
