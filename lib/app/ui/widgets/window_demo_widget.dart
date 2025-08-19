import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class WindowDemoWidget extends StatelessWidget {
  const WindowDemoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.window, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Window Controls Demo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Window positioning controls
            _buildControlSection('Window Position', [
              _buildControlButton(
                'Center',
                Icons.center_focus_strong,
                () => appWindow.alignment = Alignment.center,
              ),
              _buildControlButton(
                'Top Left',
                Icons.crop_square,
                () => appWindow.alignment = Alignment.topLeft,
              ),
              _buildControlButton(
                'Top Right',
                Icons.crop_square,
                () => appWindow.alignment = Alignment.topRight,
              ),
              _buildControlButton(
                'Bottom Left',
                Icons.crop_square,
                () => appWindow.alignment = Alignment.bottomLeft,
              ),
              _buildControlButton(
                'Bottom Right',
                Icons.crop_square,
                () => appWindow.alignment = Alignment.bottomRight,
              ),
            ]),

            const SizedBox(height: 16),

            // Window sizing controls
            _buildControlSection('Window Size', [
              _buildControlButton(
                'Small (800x600)',
                Icons.aspect_ratio,
                () => appWindow.size = const Size(800, 600),
              ),
              _buildControlButton(
                'Medium (1280x720)',
                Icons.aspect_ratio,
                () => appWindow.size = const Size(1280, 720),
              ),
              _buildControlButton(
                'Large (1920x1080)',
                Icons.aspect_ratio,
                () => appWindow.size = const Size(1920, 1080),
              ),
              _buildControlButton(
                'Fullscreen',
                Icons.fullscreen,
                () => appWindow.maximize(),
              ),
              _buildControlButton(
                'Restore',
                Icons.fullscreen_exit,
                () => appWindow.restore(),
              ),
            ]),

            const SizedBox(height: 16),

            // Window state controls
            _buildControlSection('Window State', [
              _buildControlButton(
                'Minimize',
                Icons.minimize,
                () => appWindow.minimize(),
              ),
              _buildControlButton(
                'Hide',
                Icons.visibility_off,
                () => appWindow.hide(),
              ),
              _buildControlButton(
                'Show',
                Icons.visibility,
                () => appWindow.show(),
              ),
              _buildControlButton(
                'Close',
                Icons.close,
                () => appWindow.close(),
              ),
            ]),

            const SizedBox(height: 16),

            // Window information
            _buildInfoSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSection(String title, List<Widget> controls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: controls),
      ],
    );
  }

  Widget _buildControlButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 32),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Window Information',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This demo showcases the bitsdojo_window package capabilities for customizing desktop window behavior.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
