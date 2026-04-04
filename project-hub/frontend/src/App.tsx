import axios from 'axios';
import { useEffect, useState } from 'react';

const API_BASE = 'http://localhost:5000/api';

function App() {
  const [metrics, setMetrics] = useState(null);
  const [loading, setLoading] = useState(true);
  const [lastUpdate, setLastUpdate] = useState(new Date());

  useEffect(() => {
    fetchMetrics();
    const interval = setInterval(fetchMetrics, 30000); // Refresh every 30 seconds
    return () => clearInterval(interval);
  }, []);

  const fetchMetrics = async () => {
    try {
      const response = await axios.get(`${API_BASE}/dashboard/metrics`);
      setMetrics(response.data.data);
      setLastUpdate(new Date());
      setLoading(false);
    } catch (error) {
      console.error('Error fetching metrics:', error);
      setLoading(false);
    }
  };

  const getScoreColor = (score: number) => {
    if (score >= 90) return 'text-green-400';
    if (score >= 70) return 'text-yellow-400';
    return 'text-red-400';
  };

  const getStatusIcon = (score: number) => {
    if (score >= 90) return '✓';
    if (score >= 70) return '⚠';
    return '✗';
  };

  function ProgressBar({ value, max = 100, label }): any {
    const percent = Math.min(100, Math.round((value / max) * 100));
    return (
      <div className="mb-2">
        <div className=" flex justify-between text-sm mb-1">
          <span>{label}</span>
          <span className={getScoreColor(percent)}>{percent}%</span>
        </div>
        <div className="w-full bg-darker rounded-full h-3">
          <div
            className={`h-3 rounded-full transition-all ${percent >= 80 ? 'bg-green-500' : percent >= 50 ? 'bg-yellow-500' : 'bg-red-500'}`}
            style={{ width: `${percent}%` }}
          ></div>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-dark text-light flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-primary mx-auto"></div>
          <p className="mt-4 text-xl">Loading Project HUB...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-dark text-light">
      {/* Header */}
      <header className="bg-darker border-b border-primary p-4">
        <div className="container mx-auto flex justify-between items-center">
          <h1 className="text-2xl font-bold text-primary">Steps to Recovery - Project HUB</h1>
          <div className="flex items-center space-x-4">
            <span className="text-sm text-gray-400">
              Last updated: {lastUpdate.toLocaleTimeString()}
            </span>
            <button
              onClick={fetchMetrics}
              className="bg-primary text-dark px-4 py-2 rounded hover:bg-opacity-80"
            >
              Refresh
            </button>
          </div>
        </div>
      </header>

      <div className="container mx-auto p-6">
        {/* Overall Health */}
        {metrics && (
          <div className="mb-8">
            <h2 className="text-2xl font-bold mb-4 text-primary">Overall System Health</h2>
            <div className="bg-darker p-6 rounded-lg">
              <ProgressBar
                value={metrics.code_health.score * 0.30 + metrics.security.score * 0.30 + metrics.test_coverage.coverage * 0.25 + 85 * 0.15}
                label="System Health Score"
              />
            </div>
          </div>
        )}

        {/* Metrics Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {/* Code Health */}
          <div className="bg-darker p-6 rounded-lg">
            <h3 className="text-xl font-bold mb-4 text-primary">Code Health</h3>
            {metrics && (
              <>
                <div className={`text-4xl font-bold mb-2 ${getScoreColor(metrics.code_health.score)}`}>
                  {getStatusIcon(metrics.code_health.score)} {metrics.code_health.score}%
                </div>
                <p className="text-sm text-gray-400 mb-4">
                  {metrics.code_health.errors} errors, {metrics.code_health.warnings} warnings
                </p>
                <ProgressBar value={metrics.code_health.score} label="Health Score" />
              </>
            )}
          </div>

          {/* Security */}
          <div className="bg-darker p-6 rounded-lg">
            <h3 className="text-xl font-bold mb-4 text-primary">Security</h3>
            {metrics && (
              <>
                <div className={`text-4xl font-bold mb-2 ${getScoreColor(metrics.security.score)}`}>
                  {getStatusIcon(metrics.security.score)} {metrics.security.score}%
                </div>
                <p className="text-sm text-gray-400 mb-4">
                  {metrics.security.pii_issues} PII issues
                </p>
                <ProgressBar value={metrics.security.score} label="Security Score" />
              </>
            )}
          </div>

          {/* Test Coverage */}
          <div className="bg-darker p-6 rounded-lg">
            <h3 className="text-xl font-bold mb-4 text-primary">Test Coverage</h3>
            {metrics && (
              <>
                <div className={`text-4xl font-bold mb-2 ${getScoreColor(metrics.test_coverage.coverage)}`}>
                  {metrics.test_coverage.coverage}%
                </div>
                <p className="text-sm text-gray-400 mb-4">
                  Target: 80%
                </p>
                <ProgressBar value={metrics.test_coverage.coverage} max={80} label="Coverage" />
              </>
            )}
          </div>

          {/* Git Status */}
          <div className="bg-darker p-6 rounded-lg">
            <h3 className="text-xl font-bold mb-4 text-primary">Git Status</h3>
            {metrics && (
              <>
                <div className="text-2xl font-bold mb-2">
                  {metrics.git_status.current_branch}
                </div>
                <p className="text-sm text-gray-400 mb-2">
                  {metrics.git_status.modified} modified, {metrics.git_status.untracked} untracked
                </p>
                <div className={`text-sm ${metrics.git_status.has_changes ? 'text-yellow-400' : 'text-green-400'}`}>
                  {metrics.git_status.has_changes ? '● Has changes' : '✓ Clean'}
                </div>
              </>
            )}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mb-8">
          <h2 className="text-2xl font-bold mb-4 text-primary">Quick Actions</h2>
          <div className="bg-darker p-6 rounded-lg">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <button
                onClick={() => window.open('http://localhost:5000/api/scripts/execute', '_blank')}
                className="bg-red-600 hover:bg-red-700 text-white px-6 py-3 rounded transition"
              >
                ⚠ Fix PII Leaks
              </button>
              <button
                onClick={fetchMetrics}
                className="bg-yellow-600 hover:bg-yellow-700 text-white px-6 py-3 rounded transition"
              >
                🔄 Auto-Fix Code
              </button>
              <button
                onClick={() => window.open('http://localhost:5000/api/tasks/list', '_blank')}
                className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded transition"
              >
                📋 Generate Tests
              </button>
            </div>
          </div>
        </div>

        {/* Footer */}
        <footer className="text-center text-gray-500 text-sm mt-8">
          <p>Project HUB v1.0.0 | Steps to Recovery</p>
        </footer>
      </div>
    </div>
  );
}

export default App;
