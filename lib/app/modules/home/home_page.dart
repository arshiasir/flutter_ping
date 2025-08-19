import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/status_indicator.dart';
import '../../ui/widgets/check_result_card.dart';
import '../../ui/widgets/version_manager_widget.dart';
import '../../data/models/url_model.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 8,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Image.asset('assets/images/icon.png', fit: BoxFit.cover),
            ),
            const Text('Flutter Ping'),
          ],
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.isRunningChecks
                  ? null
                  : controller.clearResults,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear Results',
            ),
          ),
        ],
      ),
      body: Obx(() => _buildBody(context)),
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
              ? AppTheme.textTertiary
              : AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.runAllChecks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallStatus(context),
            const SizedBox(height: 24),

            if (controller.isRunningChecks) ...[
              _buildProgressSection(context),
              const SizedBox(height: 24),
            ],

            _buildNetworkSection(context),
            const SizedBox(height: 24),

            _buildFlutterSection(context),
            const SizedBox(height: 24),

            _buildDoctorSection(context),
            const SizedBox(height: 24),

            _buildVersionManagerSection(context),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatus(BuildContext context) {
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
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.getOverallStatus(),
                        style: Theme.of(context).textTheme.bodyMedium,
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
                backgroundColor: AppTheme.elevatedSurface,
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

  Widget _buildProgressSection(BuildContext context) {
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

  Widget _buildNetworkSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Network Connectivity',
          'Testing access to essential Flutter development resources',
          Icons.wifi,
        ),
        const SizedBox(height: 12),

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

  Widget _buildFlutterSection(BuildContext context) {
    final flutterInfo = controller.flutterInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
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

  Widget _buildDoctorSection(BuildContext context) {
    final doctorResult = controller.doctorResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
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
              Icon(Icons.info_outline, size: 48, color: AppTheme.textTertiary),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionManagerSection(BuildContext context) {
    return const VersionManagerWidget();
  }
}
