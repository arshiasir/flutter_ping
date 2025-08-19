import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme.dart';
import '../../data/models/version_model.dart';
import '../../data/services/version_service.dart';

class VersionManagerWidget extends StatelessWidget {
  const VersionManagerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final versionService = Get.find<VersionService>();

    return Obx(() {
      final toolVersions = versionService.toolVersions;

      if (toolVersions.isEmpty) {
        return _buildEmptyState(context);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          const SizedBox(height: 12),
          ...toolVersions.values.map(
            (toolVersion) =>
                _buildToolVersionCard(context, toolVersion, versionService),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(context, versionService),
        ],
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 48, color: AppTheme.textTertiary),
              const SizedBox(height: 12),
              Text(
                'No tool versions detected yet',
                style: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    Get.find<VersionService>().refreshAllVersions(),
                icon: const Icon(Icons.refresh),
                label: const Text('Detect Versions'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.build, size: 24, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tool Versions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                'Manage and test development tool versions',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolVersionCard(
    BuildContext context,
    ToolVersion toolVersion,
    VersionService versionService,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getToolIcon(toolVersion.toolName),
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  toolVersion.toolName.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (toolVersion.isCustomVersion)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Custom',
                      style: TextStyle(
                        color: AppTheme.info,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Version information
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (toolVersion.detectedVersion != null) ...[
                        Text(
                          'Detected: ${toolVersion.detectedVersion}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (toolVersion.preferredVersion != null) ...[
                        Text(
                          'Preferred: ${toolVersion.preferredVersion}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        'Effective: ${toolVersion.effectiveVersion ?? 'Not available'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _showVersionDialog(
                        context,
                        toolVersion,
                        versionService,
                      ),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit Version',
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      onPressed: () =>
                          _testVersion(context, toolVersion, versionService),
                      icon: const Icon(Icons.play_arrow),
                      tooltip: 'Test Version',
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.success.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Last updated info
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatDateTime(toolVersion.lastUpdated)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    VersionService versionService,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => versionService.refreshAllVersions(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh All'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showAddToolDialog(context, versionService),
            icon: const Icon(Icons.add),
            label: const Text('Add Tool'),
          ),
        ),
      ],
    );
  }

  IconData _getToolIcon(String toolName) {
    switch (toolName.toLowerCase()) {
      case 'gradle':
        return Icons.build;
      case 'java':
        return Icons.code;
      case 'kotlin':
        return Icons.developer_mode;
      case 'android':
        return Icons.android;
      case 'flutter':
        return Icons.flutter_dash;
      case 'dart':
        return Icons.language;
      default:
        return Icons.build;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _showVersionDialog(
    BuildContext context,
    ToolVersion toolVersion,
    VersionService versionService,
  ) {
    final controller = TextEditingController(
      text: toolVersion.preferredVersion ?? toolVersion.detectedVersion ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set ${toolVersion.toolName.toUpperCase()} Version'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the version you want to test:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Version',
                hintText: 'e.g., 8.7, 8.8, 8.9',
                border: OutlineInputBorder(),
              ),
            ),
            if (toolVersion.detectedVersion != null) ...[
              const SizedBox(height: 16),
              Text(
                'Detected version: ${toolVersion.detectedVersion}',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (toolVersion.preferredVersion != null)
            TextButton(
              onPressed: () async {
                await versionService.clearPreferredVersion(
                  toolVersion.toolName,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Use Detected'),
            ),
          ElevatedButton(
            onPressed: () async {
              final version = controller.text.trim();
              if (version.isNotEmpty) {
                await versionService.setPreferredVersion(
                  toolVersion.toolName,
                  version,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Set Version'),
          ),
        ],
      ),
    );
  }

  void _testVersion(
    BuildContext context,
    ToolVersion toolVersion,
    VersionService versionService,
  ) {
    final version = toolVersion.effectiveVersion;
    if (version == null) {
      Get.snackbar(
        'No Version Available',
        'Please set a version for ${toolVersion.toolName} first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Show testing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Testing ${toolVersion.toolName.toUpperCase()} $version'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing version availability...'),
          ],
        ),
      ),
    );

    // Perform the test
    versionService.testToolVersion(toolVersion.toolName, version).then((
      result,
    ) {
      Navigator.of(context).pop(); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Test Result: ${toolVersion.toolName.toUpperCase()} $version',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    result.isAvailable ? Icons.check_circle : Icons.error,
                    color: result.isAvailable
                        ? AppTheme.success
                        : AppTheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    result.isAvailable ? 'Available' : 'Not Available',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: result.isAvailable
                          ? AppTheme.success
                          : AppTheme.error,
                    ),
                  ),
                ],
              ),
              if (result.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text('Error:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  result.errorMessage!,
                  style: TextStyle(color: AppTheme.error),
                ),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  void _showAddToolDialog(BuildContext context, VersionService versionService) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tool'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the name of the tool to add:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Tool Name',
                hintText: 'e.g., gradle, java, kotlin',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final toolName = controller.text.trim().toLowerCase();
              if (toolName.isNotEmpty) {
                await versionService.detectToolVersion(toolName);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add Tool'),
          ),
        ],
      ),
    );
  }
}
