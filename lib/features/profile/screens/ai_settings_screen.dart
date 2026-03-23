import 'package:flutter/material.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class AiSettingsScreen extends StatelessWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStateService.instance,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI Companion'),
            backgroundColor: AppColors.background,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text('Support behavior', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'The app can fall back to local guidance when cloud support is unavailable.',
              ),
              const SizedBox(height: AppSpacing.lg),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable AI companion'),
                subtitle: const Text('Allow the app to offer guided responses'),
                value: AppStateService.instance.aiProxyEnabled,
                onChanged: (value) =>
                    AppStateService.instance.setAiProxyEnabled(value),
              ),
              const SizedBox(height: AppSpacing.md),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.shield_outlined,
                  color: AppColors.primaryAmber,
                ),
                title: Text('Crisis-aware fallback'),
                subtitle: Text(
                  'Immediate support actions stay local and available offline',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Configuration', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.cloud_outlined,
                  color: AppColors.primaryAmber,
                ),
                title: const Text('Cloud proxy'),
                subtitle: Text(
                  AiService().isCloudAvailable
                      ? 'A cloud API key is configured. The companion can use structured cloud guidance when enabled.'
                      : 'No cloud API key is configured. Add GOOGLE_AI_API_KEY or GEMINI_API_KEY as a dart-define to enable cloud guidance.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
