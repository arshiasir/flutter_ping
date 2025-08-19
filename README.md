# Flutter System Check

A comprehensive Flutter application that performs system and network environment checks for Flutter development. Built with GetX for state management and featuring a modern, dark-themed UI.

## Features

### 🌐 Network Connectivity Testing
- Tests connectivity to essential Flutter development resources:
  - Flutter SDK releases repository
  - Dart SDK archive
  - Gradle distribution services
  - Android Gradle Plugin repository
  - Google Maven (AndroidX)
  - Maven Central
  - pub.dev package repository
  - CocoaPods
  - GitHub
  - VSCode Marketplace
  - Android Emulator System Images
  - Node.js
  - Flutter DevTools

### ⚙️ Flutter SDK & Version Check
- Verifies Flutter installation
- Displays Flutter version, channel, framework, engine, and Dart version
- Provides installation guidance if Flutter is not found

### 🩺 Flutter Doctor Integration
- Runs `flutter doctor -v` and displays comprehensive results
- Categorizes issues by severity (errors, warnings, info)
- Shows detailed explanations for each component
- Provides contextual help for resolving issues

### ⬆️ Flutter Update Check
- Checks for available Flutter updates using `flutter upgrade --dry-run`
- Shows current status and available updates
- Provides update recommendations

### 📦 Package Dependencies Check
- Analyzes project dependencies using `flutter pub outdated`
- Lists outdated packages with current and latest versions
- Provides upgrade recommendations

### 🤖 Android SDK & Tools Check
- Verifies ANDROID_SDK_ROOT configuration
- Lists installed Android platforms
- Shows available build-tools
- Provides setup guidance for Android development

## Screenshots

The app features a modern, dark-themed interface with:
- Real-time progress indicators
- Expandable result cards with detailed information
- Status badges with color-coded indicators
- Copy-to-clipboard functionality for logs and errors
- Retry functionality for failed checks

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- Android Studio or Android SDK (for Android development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd flutter_ping
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Usage

1. **Launch the app** - The app opens with an overview of the system status
2. **Run system checks** - Tap the "Run Checks" floating action button
3. **View results** - Expand each section to see detailed information
4. **Retry failed checks** - Use the retry button for individual failed components
5. **Copy information** - Use the copy buttons to share logs or error messages

## Architecture

### State Management
- **GetX**: Used for reactive state management, dependency injection, and routing
- **Controllers**: Manage business logic and state for each feature
- **Services**: Handle external process execution and network requests

### Project Structure
```
lib/
├── app/
│   ├── data/
│   │   ├── models/          # Data models and enums
│   │   └── services/        # Service layer for external APIs
│   ├── modules/
│   │   └── home/           # Home page and controller
│   ├── routes/             # GetX routing configuration
│   └── ui/
│       ├── theme.dart      # App theme and styling
│       └── widgets/        # Reusable UI components
└── main.dart               # App entry point
```

### Key Components

#### Models
- `CheckResult`: Represents the result of any system check
- `NetworkCheckItem`: Specific to network connectivity tests
- `FlutterInfo`: Flutter SDK information
- `AndroidSdkInfo`: Android SDK configuration details
- `FlutterDoctorResult`: Flutter doctor output parsing

#### Services
- `NetworkService`: Handles HTTP connectivity tests
- `FlutterService`: Executes Flutter CLI commands
- `AndroidService`: Checks Android SDK configuration

#### UI Components
- `StatusIndicator`: Shows check status with icons and animations
- `StatusBadge`: Color-coded status badges
- `CheckResultCard`: Expandable cards for detailed results
- `ProgressCard`: Progress tracking during checks

## Customization

### Adding New Checks

1. **Define the model** in `lib/app/data/models/`
2. **Create the service** in `lib/app/data/services/`
3. **Update the controller** to include the new check
4. **Add UI components** in the home page

### Modifying Theme

The app uses a comprehensive dark theme defined in `lib/app/ui/theme.dart`. Key colors:

- Primary: Purple (`#6C63FF`)
- Success: Green (`#4CAF50`)
- Warning: Orange (`#FF9800`)
- Error: Red (`#F44336`)
- Background: Dark (`#121212`)

### Network Endpoints

Network check URLs are defined in `NetworkService`. To add new endpoints:

1. Add the URL to the `_criticalUrls` list
2. Include a descriptive name and explanation
3. The service will automatically include it in checks

## Dependencies

### Core Dependencies
- `get`: State management and dependency injection
- `http`: HTTP client for network requests
- `dio`: Advanced HTTP client with better error handling

### Development Dependencies
- `device_info_plus`: Device information
- `path`: Path manipulation utilities
- `flutter_vector_icons`: Additional icon sets

## Testing

Run tests with:
```bash
flutter test
```

The app includes basic widget tests for the main interface.

## Platform Support

- ✅ **Windows**: Full support
- ✅ **macOS**: Full support
- ✅ **Linux**: Full support
- ⚠️ **Android/iOS**: Limited (some system checks may not work on mobile)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the excellent framework
- GetX contributors for the state management solution
- The open-source community for various packages used

## Troubleshooting

### Common Issues

**Flutter command not found (ProcessException)**
- This is the most common issue when Flutter works in terminal but not in the app
- **Quick Fix**: Open Command Prompt, run `flutter --version`, then restart this app
- Ensure Flutter's bin directory is in your system PATH environment variable
- On Windows, try running the app as administrator
- Restart your computer if you recently modified PATH variables

**Network checks failing**
- Check your internet connection
- Verify firewall settings
- Some corporate networks may block certain endpoints

**Android SDK not detected**
- Set the ANDROID_SDK_ROOT environment variable
- Install Android Studio or standalone Android SDK
- Accept SDK licenses using `flutter doctor --android-licenses`

**Permission denied errors**
- Ensure the app has permission to execute system commands
- On macOS/Linux, you may need to run with appropriate permissions

### Getting Help

If you encounter issues:
1. Check the detailed error messages in the app
2. Use the copy functionality to share error logs
3. Run `flutter doctor` manually to verify your setup
4. Check the Flutter documentation for setup guidance

---

Built with ❤️ using Flutter and GetX