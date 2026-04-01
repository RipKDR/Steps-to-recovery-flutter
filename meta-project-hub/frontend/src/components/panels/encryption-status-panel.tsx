'use client';

import { Lock, Key, Shield, CheckCircle } from 'lucide-react';

interface EncryptionStatusPanelProps {
  encryptionStandard?: string;
  keyManagement?: 'secure' | 'review' | 'insecure';
  encryptedEntities?: number;
  lastAudit?: string;
  compliance?: {
    aes256: boolean;
    keyRotation: boolean;
    secureStorage: boolean;
    dataProtection: boolean;
  };
}

export function EncryptionStatusPanel({
  encryptionStandard = 'AES-256',
  keyManagement = 'secure',
  encryptedEntities = 12,
  lastAudit = new Date().toISOString(),
  compliance = {
    aes256: true,
    keyRotation: true,
    secureStorage: true,
    dataProtection: true,
  },
}: EncryptionStatusPanelProps) {
  const getKeyColor = (status: string) => {
    switch (status) {
      case 'secure':
        return 'text-emerald-400 bg-emerald-500/10';
      case 'review':
        return 'text-amber-400 bg-amber-500/10';
      case 'insecure':
        return 'text-red-400 bg-red-500/10';
    }
  };

  return (
    <div className="p-6 rounded-xl bg-zinc-900 border border-zinc-800">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-emerald-500/10">
            <Lock className="text-emerald-500" size={20} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-zinc-100">
              Encryption Status
            </h3>
            <p className="text-xs text-zinc-500">
              Data protection audit
            </p>
          </div>
        </div>
        <div className={`px-3 py-1 rounded-full text-xs font-medium ${getKeyColor(keyManagement)}`}>
          Keys: {keyManagement}
        </div>
      </div>

      {/* Standard */}
      <div className="mb-6 p-4 rounded-lg bg-zinc-800/50 border border-zinc-700">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <Shield className="text-zinc-400" size={18} />
            <span className="text-sm text-zinc-400">Encryption Standard</span>
          </div>
          <span className="text-lg font-bold text-emerald-400">{encryptionStandard}</span>
        </div>
        <div className="flex items-center gap-2 text-xs text-zinc-500">
          <CheckCircle className="text-emerald-500" size={12} />
          <span>Military-grade encryption active</span>
        </div>
      </div>

      {/* Compliance Checklist */}
      <div className="mb-6">
        <div className="text-sm text-zinc-400 mb-3">Compliance Checklist</div>
        <div className="space-y-2">
          <div className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <CheckCircle className="text-emerald-500" size={16} />
              <span className="text-sm text-zinc-300">AES-256 Encryption</span>
            </div>
            <span className="text-xs text-emerald-400 font-medium">Compliant</span>
          </div>

          <div className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Key className="text-emerald-500" size={16} />
              <span className="text-sm text-zinc-300">Key Rotation</span>
            </div>
            <span className="text-xs text-emerald-400 font-medium">Compliant</span>
          </div>

          <div className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Lock className="text-emerald-500" size={16} />
              <span className="text-sm text-zinc-300">Secure Storage</span>
            </div>
            <span className="text-xs text-emerald-400 font-medium">Compliant</span>
          </div>

          <div className="p-3 rounded-lg bg-zinc-800/50 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Shield className="text-emerald-500" size={16} />
              <span className="text-sm text-zinc-300">Data Protection</span>
            </div>
            <span className="text-xs text-emerald-400 font-medium">Compliant</span>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="text-xs text-zinc-400 mb-1">Encrypted Entities</div>
          <div className="text-xl font-bold text-zinc-100">{encryptedEntities}</div>
        </div>

        <div className="p-3 rounded-lg bg-zinc-800/50">
          <div className="text-xs text-zinc-400 mb-1">Last Audit</div>
          <div className="text-sm font-medium text-zinc-100">
            {new Date(lastAudit).toLocaleDateString()}
          </div>
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3">
        <button className="flex-1 px-4 py-2 rounded-lg bg-emerald-500 hover:bg-emerald-600 text-white font-medium transition-colors">
          Run Audit
        </button>
        <button className="flex-1 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-100 font-medium transition-colors">
          View Report
        </button>
      </div>
    </div>
  );
}
