import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../theme.dart';

class FlutterPathHelper extends StatelessWidget {
  final String errorMessage;

  const FlutterPathHelper({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.warning.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Flutter PATH Issue Detected',
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Flutter is installed but not accessible from this app.',
              style: Get.theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildQuickFix(),
            const SizedBox(height: 16),
            _buildDetailedSteps(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFix() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.elevatedSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🚀 Quick Fix:',
            style: Get.theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text('1. Open Command Prompt or PowerShell'),
          const Text('2. Run: flutter --version'),
          const Text('3. If it works, close and restart this app'),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _copyCommand('flutter --version'),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy Command'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warning.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.warning,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedSteps() {
    return ExpansionTile(
      title: Text(
        'Detailed Troubleshooting',
        style: Get.theme.textTheme.titleSmall,
      ),
      children: [
        const SizedBox(height: 16),
        _buildTroubleshootingStep(
          '1. Check Flutter Installation',
          'Verify Flutter is properly installed in your system.',
          Icons.check_circle,
          AppTheme.success,
        ),
        _buildTroubleshootingStep(
          '2. Add to PATH',
          'Add Flutter bin directory to your system PATH environment variable.',
          Icons.settings,
          AppTheme.info,
        ),
        _buildTroubleshootingStep(
          '3. Restart Terminal',
          'Close and reopen your terminal/command prompt after PATH changes.',
          Icons.refresh,
          AppTheme.warning,
        ),
        _buildTroubleshootingStep(
          '4. Verify Installation',
          'Run "flutter doctor" to check for any other issues.',
          Icons.medical_services,
          AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildTroubleshootingStep(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyCommand(String command) {
    Clipboard.setData(ClipboardData(text: command));
    Get.snackbar(
      'Command Copied',
      'The command has been copied to your clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.success.withValues(alpha: 0.1),
      colorText: AppTheme.success,
    );
  }
}
