import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../theme.dart';
import '../widgets/status_indicator.dart';
import '../../data/models/url_model.dart';

class CheckResultCard extends StatelessWidget {
  final String title;
  final String description;
  final CheckStatus status;
  final String? details;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool showDetails;

  const CheckResultCard({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    this.details,
    this.errorMessage,
    this.onRetry,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: StatusIndicator(
          status: status,
          animate: status == CheckStatus.running,
        ),
        title: Text(title, style: Get.theme.textTheme.titleMedium),
        subtitle: Text(description, style: Get.theme.textTheme.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadge(status: status),
            const SizedBox(width: 8),
            if (onRetry != null && status == CheckStatus.failed)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRetry,
                tooltip: 'Retry',
              ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [if (showDetails) _buildDetailsSection()],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (details != null) ...[
            Text('Details:', style: Get.theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.elevatedSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.textTertiary.withValues(alpha: 0.3),
                ),
              ),
              child: SelectableText(
                details!,
                style: Get.theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(details!),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.elevatedSurface,
                    foregroundColor: AppTheme.textSecondary,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
          if (errorMessage != null) ...[
            if (details != null) const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Error Details',
                        style: Get.theme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    errorMessage!,
                    style: Get.theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.error,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Details copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.success.withValues(alpha: 0.1),
      colorText: AppTheme.success,
    );
  }
}

class NetworkCheckCard extends StatelessWidget {
  final NetworkCheckItem item;
  final VoidCallback? onRetry;

  const NetworkCheckCard({super.key, required this.item, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return CheckResultCard(
      title: item.name,
      description: item.description,
      status: item.status,
      details: _buildNetworkDetails(),
      errorMessage: item.errorMessage,
      onRetry: onRetry,
    );
  }

  String _buildNetworkDetails() {
    final buffer = StringBuffer();
    buffer.writeln('URL: ${item.url}');

    if (item.httpCode != null) {
      buffer.writeln('HTTP Status: ${item.httpCode}');
    }

    buffer.writeln('Status: ${item.status.name.toUpperCase()}');

    if (item.status == CheckStatus.success) {
      buffer.writeln(
        '\n✅ This endpoint is accessible and responding correctly.',
      );
    } else if (item.status == CheckStatus.warning) {
      buffer.writeln(
        '\n⚠️ This endpoint responded but with a non-200 status code.',
      );
    } else if (item.status == CheckStatus.failed) {
      buffer.writeln('\n❌ This endpoint is not accessible. This may affect:');
      buffer.writeln('  • Package downloads and updates');
      buffer.writeln('  • Build processes');
      buffer.writeln('  • Development tool functionality');
    }

    return buffer.toString();
  }
}
