import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodySmall,
        ),
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
        children: [
          if (showDetails) _buildDetailsSection(context),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (details != null) ...[
            Text(
              'Details:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.elevatedSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.textTertiary.withOpacity(0.3),
                ),
              ),
              child: SelectableText(
                details!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context, details!),
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
            Text(
              'Error:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.error.withOpacity(0.3),
                ),
              ),
              child: SelectableText(
                errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.error,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context, errorMessage!),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy Error'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error.withOpacity(0.1),
                    foregroundColor: AppTheme.error,
                    elevation: 0,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class NetworkCheckCard extends StatelessWidget {
  final NetworkCheckItem item;
  final VoidCallback? onRetry;

  const NetworkCheckCard({
    super.key,
    required this.item,
    this.onRetry,
  });

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
      buffer.writeln('\n✅ This endpoint is accessible and responding correctly.');
    } else if (item.status == CheckStatus.warning) {
      buffer.writeln('\n⚠️ This endpoint responded but with a non-200 status code.');
    } else if (item.status == CheckStatus.failed) {
      buffer.writeln('\n❌ This endpoint is not accessible. This may affect:');
      buffer.writeln('  • Package downloads and updates');
      buffer.writeln('  • Build processes');
      buffer.writeln('  • Development tool functionality');
    }
    
    return buffer.toString();
  }
}
