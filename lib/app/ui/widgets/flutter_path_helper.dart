import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildQuickFix(context),
            const SizedBox(height: 16),
            _buildDetailedSteps(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFix(BuildContext context) {
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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                onPressed: () => _copyCommand(context, 'flutter --version'),
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

  Widget _buildDetailedSteps(BuildContext context) {
    return ExpansionTile(
      title: Text(
        'Detailed Troubleshooting',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep(context, '1. Verify Flutter Installation', [
                'Open terminal/command prompt',
                'Run: flutter --version',
                'Should show Flutter version info',
              ]),
              const SizedBox(height: 16),
              _buildStep(context, '2. Check PATH Environment', [
                'Ensure Flutter bin directory is in PATH',
                'On Windows: Add C:\\flutter\\bin to PATH',
                'Restart terminal after changing PATH',
              ]),
              const SizedBox(height: 16),
              _buildStep(context, '3. Alternative Solutions', [
                'Try running this app as administrator',
                'Restart your computer if PATH was changed',
                'Check if antivirus is blocking execution',
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep(BuildContext context, String title, List<String> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(child: Text(step)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _copyCommand(BuildContext context, String command) {
    Clipboard.setData(ClipboardData(text: command));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $command'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.warning,
      ),
    );
  }
}
