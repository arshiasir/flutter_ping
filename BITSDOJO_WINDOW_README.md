# Bitsdojo Window Integration

This Flutter project has been integrated with the [bitsdojo_window](https://pub.dev/packages/bitsdojo_window) package to provide custom window functionality for desktop platforms (Windows, macOS, and Linux).

## Features Added

### 1. Custom Window Frame
- Removed standard OS title bars
- Custom title bar with app branding
- Draggable window area
- Custom minimize, maximize, and close buttons

### 2. Window Controls
- **Positioning**: Center, top-left, top-right, bottom-left, bottom-right
- **Sizing**: Small (800x600), Medium (1280x720), Large (1920x1080), Fullscreen
- **State**: Minimize, hide, show, close
- **Customization**: Window title, minimum size, initial size

### 3. Platform-Specific Configuration

#### Windows (`windows/runner/main.cpp`)
```cpp
#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>

// Configure bitsdojo_window
auto bdw = bitsdojo_window_configure(BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP);
```

#### macOS (`macos/Runner/MainFlutterWindow.swift`)
```swift
import bitsdojo_window_macos

class MainFlutterWindow: BitsdojoWindow {
  override func bitsdojo_window_configure() -> UInt {
    return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
  }
}
```

#### Linux (`linux/runner/my_application.cc`)
```cpp
#include <bitsdojo_window_linux/bitsdojo_window_plugin.h>

// Configure bitsdojo_window
auto bdw = bitsdojo_window_from(window);
bdw->setCustomFrame(true);
```

### 4. Flutter Integration (`lib/main.dart`)
```dart
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() {
  runApp(const FlutterPingApp());

  // Configure bitsdojo_window for desktop platforms
  doWhenWindowReady(() {
    const initialSize = Size(1280, 720);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Flutter Ping";
    appWindow.show();
  });
}
```

## Custom Widgets Created

### 1. CustomTitleBar (`lib/app/ui/widgets/custom_title_bar.dart`)
- Custom title bar with app branding
- Draggable area for moving the window
- Window control buttons (minimize, maximize, close)
- Clear results button integrated

### 2. WindowDemoWidget (`lib/app/ui/widgets/window_demo_widget.dart`)
- Interactive demo of window controls
- Window positioning controls
- Window sizing controls
- Window state controls

## Usage

### Basic Window Operations
```dart
// Position window
appWindow.alignment = Alignment.center;

// Resize window
appWindow.size = const Size(800, 600);

// Minimize/Maximize
appWindow.minimize();
appWindow.maximize();
appWindow.restore();

// Show/Hide
appWindow.hide();
appWindow.show();

// Close
appWindow.close();
```

### Window Configuration
```dart
// Set window properties
appWindow.title = "My App";
appWindow.minSize = const Size(400, 300);
appWindow.size = const Size(800, 600);
appWindow.alignment = Alignment.center;
```

## Dependencies

The following dependency has been added to `pubspec.yaml`:
```yaml
dependencies:
  bitsdojo_window: ^0.1.6
```

## Building for Desktop

To build and run the application for desktop platforms:

### Windows
```bash
flutter run -d windows
```

### macOS
```bash
flutter run -d macos
```

### Linux
```bash
flutter run -d linux
```

## Troubleshooting

### Common Issues

1. **Window not showing**: Ensure `appWindow.show()` is called after `doWhenWindowReady()`
2. **Custom frame not working**: Verify platform-specific configuration files are properly modified
3. **Build errors**: Run `flutter clean` and `flutter pub get` before rebuilding

### Platform-Specific Notes

- **Windows**: Requires Visual Studio with C++ development tools
- **macOS**: Requires Xcode and macOS development tools
- **Linux**: Requires GTK development libraries

## Additional Resources

- [bitsdojo_window Package](https://pub.dev/packages/bitsdojo_window)
- [Flutter Desktop Development](https://docs.flutter.dev/desktop)
- [Platform-Specific Code](https://docs.flutter.dev/desktop/platform-integration)

## License

This integration follows the same license as the bitsdojo_window package (MIT License).
