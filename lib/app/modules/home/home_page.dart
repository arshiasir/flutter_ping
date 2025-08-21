import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/status_indicator.dart';
import '../../ui/widgets/check_result_card.dart';
import '../../ui/widgets/version_manager_widget.dart';
import '../../ui/widgets/custom_title_bar.dart';
import '../../data/models/url_model.dart';
import '../../data/models/version_model.dart';
import '../../data/services/version_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom title bar for desktop platforms
          const CustomTitleBar(),
          // Main content
          Expanded(child: Obx(() => _buildBody())),
        ],
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: controller.isRunningChecks
              ? null
              : controller.runAllChecks,
          icon: Icon(
            controller.isRunningChecks ? Icons.refresh : Icons.play_arrow,
          ),
          label: Text(controller.isRunningChecks ? 'Running...' : 'Run Checks'),
          backgroundColor: controller.isRunningChecks
              ? Get.theme.colorScheme.surface
              : AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: controller.runAllChecks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallStatus(),
            const SizedBox(height: 24),

            if (controller.isRunningChecks) ...[
              _buildProgressSection(),
              const SizedBox(height: 24),
            ],

            _buildNetworkSection(),
            const SizedBox(height: 24),

            _buildFlutterSection(),
            const SizedBox(height: 24),

            _buildDoctorSection(),
            const SizedBox(height: 24),

            _buildVersionManagerSection(),
            const SizedBox(height: 100), // Space for FAB
            Row(
              spacing: 16,
              children: [
                Text("Source Code", style: Get.theme.textTheme.bodySmall),
                TextButton(
                  onPressed: () {
                    launchUrl(
                      Uri.parse('https://github.com/arshiasir/flutter_ping'),
                    );
                  },
                  child: const Text('GitHub'),
                ),
                Text("Version: 1.0.0", style: Get.theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  controller.hasErrors
                      ? Icons.error
                      : controller.hasWarnings
                      ? Icons.warning
                      : controller.overallProgress > 0
                      ? Icons.check_circle
                      : Icons.info,
                  color: controller.hasErrors
                      ? AppTheme.error
                      : controller.hasWarnings
                      ? AppTheme.warning
                      : controller.overallProgress > 0
                      ? AppTheme.success
                      : AppTheme.info,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Status',
                        style: Get.theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.getOverallStatus(),
                        style: Get.theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (controller.overallProgress > 0) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: controller.overallProgress,
                backgroundColor: Get.theme.colorScheme.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return ProgressCard(
      title: controller.currentCheckName,
      subtitle: 'System check in progress...',
      progress: controller.overallProgress,
      trailing: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildNetworkSection() {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.wifi, size: 24, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Network Connectivity',
                          style: Get.theme.textTheme.headlineSmall,
                        ),
                        Text(
                          'Testing access to essential Flutter development resources',
                          style: Get.theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => controller.isVersionManagerOpen.value =
                  !controller.isVersionManagerOpen.value,
              icon: const Icon(Icons.settings, size: 24),
            ),
          ],
        ),
        Obx(
          () => controller.isVersionManagerOpen.value
              ? _buildNetworkVersionControls()
              : const SizedBox.shrink(),
        ),

        if (controller.networkResults.isEmpty && !controller.isRunningChecks)
          _buildEmptyState('No network checks performed yet')
        else
          ...controller.networkResults.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NetworkCheckCard(
                item: item,
                onRetry: () => controller.retryNetworkCheck(item),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNetworkVersionControls() {
    final versionService = Get.find<VersionService>();

    return Obx(() {
      final toolVersions = versionService.toolVersions;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.settings, size: 20, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Version Settings for Network Tests',
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Gradle version control
              _buildVersionControlRow(
                'Gradle',
                toolVersions['gradle'],
                versionService,
                'gradle',
              ),

              const SizedBox(height: 12),

              // Android Gradle Plugin version control
              _buildVersionControlRow(
                'Android Gradle Plugin',
                toolVersions['gradle'], // Use Gradle version to determine plugin version
                versionService,
                'gradle',
                isPlugin: true,
              ),

              const SizedBox(height: 12),

              // Show current effective versions
              _buildEffectiveVersionsDisplay(toolVersions, versionService),

              const SizedBox(height: 16),

              // Apply and test button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Refresh network tests with new versions
                        controller.refreshNetworkChecks();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Test with Current Versions'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => versionService.refreshAllVersions(),
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Auto-Detect'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildVersionControlRow(
    String toolName,
    ToolVersion? toolVersion,
    VersionService versionService,
    String serviceKey, {
    bool isPlugin = false,
  }) {
    final controller = TextEditingController(
      text: toolVersion?.preferredVersion ?? toolVersion?.detectedVersion ?? '',
    );

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            toolName,
            style: Get.theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Version',
              hintText: isPlugin
                  ? 'Auto-detected from Gradle'
                  : 'e.g., 8.7, 8.8',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) {
              // Update the version in real-time
              if (value.isNotEmpty) {
                versionService.setPreferredVersion(serviceKey, value);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        if (toolVersion?.detectedVersion != null)
          Expanded(
            flex: 2,
            child: Text(
              'Detected: ${toolVersion!.detectedVersion}',
              style: Get.theme.textTheme.bodySmall?.copyWith(
                color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        const SizedBox(width: 8),
        if (toolVersion?.preferredVersion != null)
          IconButton(
            onPressed: () async {
              await versionService.clearPreferredVersion(serviceKey);
              controller.text = toolVersion?.detectedVersion ?? '';
            },
            icon: const Icon(Icons.clear, size: 18),
            tooltip: 'Use detected version',
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.textTertiary.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(8),
            ),
          ),
      ],
    );
  }

  Widget _buildFlutterSection() {
    final flutterInfo = controller.flutterInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Flutter SDK',
          'Flutter installation and version information',
          Icons.developer_board,
        ),
        const SizedBox(height: 12),

        if (flutterInfo == null && !controller.isRunningChecks)
          _buildEmptyState('Flutter SDK not checked yet')
        else if (flutterInfo != null)
          CheckResultCard(
            title: 'Flutter SDK ${flutterInfo.version ?? 'Unknown'}',
            description: 'Flutter development framework',
            status: flutterInfo.isInstalled
                ? CheckStatus.success
                : CheckStatus.failed,
            details: 'Flutter SDK details would go here',
            errorMessage: flutterInfo.errorMessage,
          ),
      ],
    );
  }

  Widget _buildDoctorSection() {
    final doctorResult = controller.doctorResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Flutter Doctor',
          'Development environment health check',
          Icons.medical_services,
        ),
        const SizedBox(height: 12),

        if (doctorResult == null && !controller.isRunningChecks)
          _buildEmptyState('Flutter doctor not run yet')
        else if (doctorResult != null)
          CheckResultCard(
            title: 'Development Environment',
            description: 'Flutter doctor comprehensive check',
            status: doctorResult.isHealthy
                ? CheckStatus.success
                : doctorResult.issues.any((i) => i.severity == 'error')
                ? CheckStatus.failed
                : CheckStatus.warning,
            details: doctorResult.rawOutput,
            errorMessage: doctorResult.errorMessage,
            onRetry: controller.retryFlutterDoctor,
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String description, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Get.theme.textTheme.headlineSmall),
              Text(description, style: Get.theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
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
                message,
                style: TextStyle(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionManagerSection() {
    return const VersionManagerWidget();
  }

  Widget _buildEffectiveVersionsDisplay(
    Map<String, ToolVersion> toolVersions,
    VersionService versionService,
  ) {
    final gradleVersion = toolVersions['gradle']?.effectiveVersion;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.elevatedSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.textTertiary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Network Test Versions:',
            style: Get.theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gradle: ${gradleVersion ?? 'Not set'}',
                  style: Get.theme.textTheme.bodySmall,
                ),
              ),
              if (gradleVersion != null) ...[
                Expanded(
                  child: Text(
                    'Plugin: ${_getCompatiblePluginVersion(gradleVersion)}',
                    style: Get.theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getCompatiblePluginVersion(String gradleVersion) {
    final version = double.tryParse(gradleVersion.split('.').take(2).join('.'));
    if (version == null) return 'Unknown';

    // Compatibility matrix (simplified)
    if (version >= 8.0 && version < 8.1) return '8.0.2';
    if (version >= 8.1 && version < 8.2) return '8.1.4';
    if (version >= 8.2 && version < 8.3) return '8.2.2';
    if (version >= 8.3 && version < 8.4) return '8.3.2';
    if (version >= 8.4 && version < 8.5) return '8.4.2';
    if (version >= 8.5 && version < 8.6) return '8.5.2';
    if (version >= 8.6 && version < 8.7) return '8.6.2';
    if (version >= 8.7 && version < 8.8) return '8.7.2';
    if (version >= 8.8 && version < 8.9) return '8.8.2';
    if (version >= 8.9 && version < 9.0) return '8.9.2';

    return 'Unknown';
  }
}
