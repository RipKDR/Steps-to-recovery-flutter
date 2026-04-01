/**
 * API Service
 * Connects frontend to Meta Project HUB backend
 */

const API_BASE = 'http://localhost:8000/v1';

// Generic fetch wrapper with error handling
async function fetchApi<T>(endpoint: string): Promise<T> {
  try {
    const response = await fetch(`${API_BASE}${endpoint}`, {
      headers: {
        'Content-Type': 'application/json',
      },
    });
    
    if (!response.ok) {
      throw new Error(`API Error: ${response.status}`);
    }
    
    return response.json();
  } catch (error) {
    console.error(`[API] ${endpoint}:`, error);
    throw error;
  }
}

// Dashboard API
export const dashboardApi = {
  getOverview: () => fetchApi<DashboardOverview>('/dashboard/overview'),
  getQuickStats: () => fetchApi<QuickStats>('/dashboard/quick-stats'),
};

// Flutter API
export const flutterApi = {
  getCodeHealth: () => fetchApi<CodeHealth>('/flutter/code-health'),
  getTestCoverage: () => fetchApi<TestCoverage>('/flutter/test-coverage'),
  getBuildStatus: () => fetchApi<BuildStatus>('/flutter/build-status'),
  getDependencies: () => fetchApi<Dependencies>('/flutter/dependencies'),
  getPerformance: () => fetchApi<Performance>('/flutter/performance'),
  getFeatureTracker: () => fetchApi<FeatureTracker>('/flutter/features'),
};

// Meta-Systems API
export const metaSystemsApi = {
  getStatus: () => fetchApi<MetaSystemsStatus>('/meta-systems/status'),
  runScan: () => fetchApi<{ success: boolean }>('/meta-systems/scan'),
};

// Agent API
export const agentsApi = {
  getStatus: () => fetchApi<AgentStatus>('/agents/status'),
  getSessions: () => fetchApi<Sessions>('/sessions/list'),
  getSkills: () => fetchApi<Skills>('/skills/list'),
};

// Tasks API
export const tasksApi = {
  getKanban: () => fetchApi<KanbanBoard>('/tasks/kanban'),
  getSprint: () => fetchApi<Sprint>('/tasks/sprint'),
  getBacklog: () => fetchApi<Backlog>('/tasks/backlog'),
};

// Memory API
export const memoryApi = {
  getSemantic: () => fetchApi<SemanticMemory>('/memory/semantic'),
  getEpisodic: () => fetchApi<EpisodicMemory>('/memory/episodic'),
  getWorking: () => fetchApi<WorkingMemory>('/memory/working'),
};

// Security API
export const securityApi = {
  getAudit: () => fetchApi<SecurityAudit>('/security/audit'),
  getPIIScan: () => fetchApi<PIIScan>('/security/pii-scan'),
  getEncryption: () => fetchApi<Encryption>('/security/encryption'),
};

// Type Definitions
export interface DashboardOverview {
  success: boolean;
  data: {
    summary: {
      total_agents: number;
      active_agents: number;
      active_sessions: number;
      tasks_total: number;
      tasks_pending: number;
      security_score: number;
      code_health: number;
      test_coverage: number;
    };
    agents: { online: number; offline: number; busy: number; idle: number };
    flutter: { code_health_score: number; errors: number; warnings: number; test_coverage: number };
    meta_systems: { last_scan: string; issues_found: number; issues_fixed: number };
    tasks: { inbox: number; in_progress: number; review: number; done_today: number };
    security: { trust_score: number; pii_issues: number; encryption_status: string };
    activity: Activity[];
  };
}

export interface QuickStats {
  agents: { online: number; total: number };
  sessions: { active: number };
  tasks: { pending: number };
  security: { score: number };
}

export interface Activity {
  id: string;
  type: string;
  message: string;
  timestamp: string;
}

export interface CodeHealth {
  success: boolean;
  data: { score: number; errors: number; warnings: number; last_analyzed: string };
}

export interface TestCoverage {
  success: boolean;
  data: { coverage: number; total_files: number; tested_files: number };
}

export interface BuildStatus {
  success: boolean;
  data: { status: string; platform: string; built_at: string };
}

export interface Dependencies {
  success: boolean;
  data: { total: number; outdated: number; vulnerable: number; latest: number };
}

export interface Performance {
  success: boolean;
  data: { app_size: string; load_time: string; jank_count: number; frame_budget: number };
}

export interface FeatureTracker {
  success: boolean;
  data: { total: number; completed: number; in_progress: number; planned: number };
}

export interface MetaSystemsStatus {
  success: boolean;
  data: { last_scan: string; scripts_available: number; issues_found: number; issues_fixed: number };
}

export interface AgentStatus {
  success: boolean;
  data: { agents: Agent[] };
}

export interface Agent {
  id: string;
  name: string;
  status: 'online' | 'offline' | 'busy' | 'idle';
  uptime: string;
}

export interface Sessions {
  success: boolean;
  data: { sessions: Session[] };
}

export interface Session {
  id: string;
  agent: string;
  duration: string;
  status: 'active' | 'completed' | 'failed';
}

export interface Skills {
  success: boolean;
  data: { installed: number; available: number; outdated: number };
}

export interface KanbanBoard {
  success: boolean;
  data: { columns: Column[] };
}

export interface Column {
  id: string;
  name: string;
  tasks: Task[];
}

export interface Task {
  id: string;
  title: string;
  status: string;
  priority: string;
}

export interface Sprint {
  success: boolean;
  data: { sprint_number: number; days_remaining: number; story_points: StoryPoints; velocity: number };
}

export interface StoryPoints {
  total: number;
  completed: number;
  in_progress: number;
  todo: number;
}

export interface Backlog {
  success: boolean;
  data: { total_items: number; priority: Priority; estimated_hours: number };
}

export interface Priority {
  high: number;
  medium: number;
  low: number;
}

export interface SemanticMemory {
  success: boolean;
  data: { patterns: Pattern[]; categories: Category[] };
}

export interface Pattern {
  id: string;
  name: string;
  confidence: number;
  applications: number;
  category: string;
}

export interface Category {
  name: string;
  count: number;
}

export interface EpisodicMemory {
  success: boolean;
  data: { episodes: Episode[] };
}

export interface Episode {
  id: string;
  date: string;
  skill: string;
  outcome: 'success' | 'partial' | 'failure';
  rating: number;
}

export interface WorkingMemory {
  success: boolean;
  data: { session: SessionInfo; active_contexts: number; short_term_items: number; attention_focus: string };
}

export interface SessionInfo {
  id: string;
  started: string;
  duration: string;
  context_size: number;
}

export interface SecurityAudit {
  success: boolean;
  data: { trust_score: number; pii_issues: number; encryption_status: string; last_audit: string };
}

export interface PIIScan {
  success: boolean;
  data: { issues: PIIIssue[] };
}

export interface PIIIssue {
  file: string;
  type: 'email' | 'phone' | 'password' | 'token';
  severity: 'critical' | 'warning' | 'info';
  status: 'fixed' | 'pending' | 'ignored';
}

export interface Encryption {
  success: boolean;
  data: { standard: string; key_management: string; encrypted_entities: number; compliance: Compliance };
}

export interface Compliance {
  aes256: boolean;
  key_rotation: boolean;
  secure_storage: boolean;
  data_protection: boolean;
}
