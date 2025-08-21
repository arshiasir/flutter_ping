import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme.dart';
import '../../data/models/version_model.dart';
import '../../data/models/url_model.dart';
import '../../data/services/version_service.dart';
import 'status_indicator.dart';

class VersionManagerWidget extends StatelessWidget {
  const VersionManagerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final versionService = Get.find<VersionService>();

    return Obx(() {
      final toolVersions = versionService.toolVersions;

      if (toolVersions.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 12),
          ...toolVersions.values.map(
            (toolVersion) => _buildToolVersionCard(toolVersion, versionService),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(versionService),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No tool versions detected yet',
                style: TextStyle(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
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

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(Icons.build, size: 24, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tool Versions', style: Get.theme.textTheme.headlineSmall),
              Text(
                'Manage and test development tool versions',
                style: Get.theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolVersionCard(
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
                Icon(Icons.build, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    toolVersion.toolName,
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusIndicator(
                  status: toolVersion.hasVersion
                      ? CheckStatus.success
                      : CheckStatus.failed,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildVersionInfo(toolVersion),
            const SizedBox(height: 12),
            _buildVersionControls(toolVersion, versionService),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo(ToolVersion toolVersion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildVersionRow(
                'Detected',
                toolVersion.detectedVersion ?? 'Not detected',
                toolVersion.detectedVersion != null
                    ? AppTheme.success
                    : Get.theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVersionRow(
                'Preferred',
                toolVersion.preferredVersion ?? 'Auto',
                toolVersion.preferredVersion != null
                    ? AppTheme.primaryColor
                    : Get.theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVersionRow(
                'Effective',
                toolVersion.effectiveVersion ?? 'Not set',
                toolVersion.effectiveVersion != null
                    ? AppTheme.info
                    : Get.theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        if (toolVersion.isUserDefined) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'User-defined version',
              style: Get.theme.textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVersionRow(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Get.theme.textTheme.bodyMedium),
        const SizedBox(height: 2),
        Text(
          value,
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVersionControls(
    ToolVersion toolVersion,
    VersionService versionService,
  ) {
    final controller = TextEditingController(
      text: toolVersion.preferredVersion ?? '',
    );

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Preferred Version',
              hintText: 'e.g., 8.7',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                versionService.setPreferredVersion(
                  toolVersion.toolName.toLowerCase(),
                  value,
                );
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () async {
            await versionService.clearPreferredVersion(
              toolVersion.toolName.toLowerCase(),
            );
            controller.text = '';
          },
          icon: const Icon(Icons.clear, size: 18),
          tooltip: 'Use detected version',
          style: IconButton.styleFrom(
            backgroundColor:
                Get.theme.colorScheme.onSurface.withOpacity(0.06),
            padding: const EdgeInsets.all(8),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _testToolVersion(toolVersion),
          icon: const Icon(Icons.play_arrow, size: 18),
          tooltip: 'Test version',
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  void _testToolVersion(ToolVersion toolVersion) {
    final version = toolVersion.effectiveVersion;
    if (version == null) {
      Get.snackbar(
        'No Version Available',
        'Please set a version for ${toolVersion.toolName} first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'Testing Version',
      'Testing ${toolVersion.toolName} $version...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _buildActionButtons(VersionService versionService) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => versionService.refreshAllVersions(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh All Versions'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => versionService.refreshAllVersions(),
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Auto-Detect'),
          ),
        ),
      ],
    );
  }
}
