/**
 * WebSocket Hook
 * Real-time connection to backend for live updates
 */

import { useEffect, useCallback, useRef } from 'react';
import { useDashboardStore } from '@/store/dashboard-store';

const WS_URL = 'ws://localhost:8000/ws';
const RECONNECT_INTERVAL = 5000; // 5 seconds

export function useWebSocket() {
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout>();

  const {
    setMetrics,
    addActivity,
    setWebSocketConnected,
    setError,
  } = useDashboardStore();

  const connect = useCallback(() => {
    try {
      const ws = new WebSocket(WS_URL);

      ws.onopen = () => {
        console.log('[WebSocket] Connected');
        setWebSocketConnected(true);
        setError(null);
      };

      ws.onmessage = (event) => {
        try {
          const message = JSON.parse(event.data);

          if (message.type === 'metrics_update') {
            setMetrics(message.data);
          } else if (message.type === 'activity') {
            addActivity(message.data);
          }
        } catch (error) {
          console.error('[WebSocket] Parse error:', error);
        }
      };

      ws.onclose = () => {
        console.log('[WebSocket] Disconnected');
        setWebSocketConnected(false);

        // Reconnect after delay
        reconnectTimeoutRef.current = setTimeout(() => {
          console.log('[WebSocket] Reconnecting...');
          connect();
        }, RECONNECT_INTERVAL);
      };

      ws.onerror = (error) => {
        console.error('[WebSocket] Error:', error);
        setError('WebSocket connection failed');
      };

      wsRef.current = ws;
    } catch (error) {
      console.error('[WebSocket] Connection error:', error);
      setError('Failed to connect to WebSocket');
    }
  }, [setMetrics, addActivity, setWebSocketConnected, setError]);

  const disconnect = useCallback(() => {
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
    }
    if (wsRef.current) {
      wsRef.current.close();
      wsRef.current = null;
    }
    setWebSocketConnected(false);
  }, [setWebSocketConnected]);

  const sendMessage = useCallback((message: object) => {
    if (wsRef.current && wsRef.current.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify(message));
    }
  }, []);

  useEffect(() => {
    connect();

    return () => {
      disconnect();
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }
    };
  }, [connect, disconnect]);

  return {
    connected: useDashboardStore((state) => state.websocketConnected),
    sendMessage,
    reconnect: connect,
    disconnect,
  };
}
