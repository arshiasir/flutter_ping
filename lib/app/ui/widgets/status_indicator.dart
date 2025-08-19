import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme.dart';
import '../../data/models/url_model.dart';

class StatusIndicator extends StatelessWidget {
  final CheckStatus status;
  final double size;
  final bool animate;

  const StatusIndicator({
    super.key,
    required this.status,
    this.size = 24,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case CheckStatus.success:
        color = AppTheme.success;
        icon = Icons.check_circle;
        break;
      case CheckStatus.failed:
        color = AppTheme.error;
        icon = Icons.error;
        break;
      case CheckStatus.warning:
        color = AppTheme.warning;
        icon = Icons.warning;
        break;
      case CheckStatus.running:
        color = AppTheme.info;
        icon = Icons.refresh;
        break;
      case CheckStatus.pending:
        color = AppTheme.textTertiary;
        icon = Icons.schedule;
        break;
    }

    Widget iconWidget = Icon(icon, color: color, size: size);

    if (animate && status == CheckStatus.running) {
      iconWidget = AnimatedRotation(
        turns: 1,
        duration: const Duration(seconds: 1),
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}

class StatusBadge extends StatelessWidget {
  final CheckStatus status;
  final String? text;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.text,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status) {
      case CheckStatus.success:
        backgroundColor = AppTheme.success.withValues(alpha: 0.1);
        textColor = AppTheme.success;
        displayText = text ?? 'SUCCESS';
        break;
      case CheckStatus.failed:
        backgroundColor = AppTheme.error.withValues(alpha: 0.1);
        textColor = AppTheme.error;
        displayText = text ?? 'FAILED';
        break;
      case CheckStatus.warning:
        backgroundColor = AppTheme.warning.withValues(alpha: 0.1);
        textColor = AppTheme.warning;
        displayText = text ?? 'WARNING';
        break;
      case CheckStatus.running:
        backgroundColor = AppTheme.info.withValues(alpha: 0.1);
        textColor = AppTheme.info;
        displayText = text ?? 'RUNNING';
        break;
      case CheckStatus.pending:
        backgroundColor = AppTheme.textTertiary.withValues(alpha: 0.1);
        textColor = AppTheme.textTertiary;
        displayText = text ?? 'PENDING';
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        displayText,
        style: Get.theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Widget? trailing;

  const ProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Get.theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Get.theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.elevatedSurface,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 16), trailing!],
          ],
        ),
      ),
    );
  }
}
