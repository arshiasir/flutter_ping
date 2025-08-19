import 'package:get/get.dart';
import '../../data/models/url_model.dart';
import '../../data/models/system_info_model.dart';
import '../../data/services/network_service.dart';
import '../../data/services/flutter_service.dart';
import '../../data/services/android_service.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find<HomeController>();

  // Observable state
  final RxBool _isRunningChecks = false.obs;
  final RxList<NetworkCheckItem> _networkResults = <NetworkCheckItem>[].obs;
  final Rx<FlutterInfo?> _flutterInfo = Rx<FlutterInfo?>(null);
  final Rx<FlutterDoctorResult?> _doctorResult = Rx<FlutterDoctorResult?>(null);
  final Rx<CheckResult?> _upgradeResult = Rx<CheckResult?>(null);
  final RxList<PubPackageInfo> _pubPackages = <PubPackageInfo>[].obs;
  final Rx<AndroidSdkInfo?> _androidInfo = Rx<AndroidSdkInfo?>(null);
  final RxString _currentCheckName = ''.obs;
  final RxDouble _overallProgress = 0.0.obs;
  final RxInt _completedChecks = 0.obs;
  final RxInt _totalChecks = 6.obs; // Network, Flutter, Doctor, Upgrade, Pub, Android

  // Services
  late final NetworkService _networkService;
  late final FlutterService _flutterService;
  late final AndroidService _androidService;

  // Getters
  bool get isRunningChecks => _isRunningChecks.value;
  List<NetworkCheckItem> get networkResults => _networkResults.toList();
  FlutterInfo? get flutterInfo => _flutterInfo.value;
  FlutterDoctorResult? get doctorResult => _doctorResult.value;
  CheckResult? get upgradeResult => _upgradeResult.value;
  List<PubPackageInfo> get pubPackages => _pubPackages.toList();
  AndroidSdkInfo? get androidInfo => _androidInfo.value;
  String get currentCheckName => _currentCheckName.value;
  double get overallProgress => _overallProgress.value;
  
  // Computed properties
  bool get hasNetworkIssues => _networkResults.any((item) => item.status == CheckStatus.failed);
  bool get hasWarnings => _networkResults.any((item) => item.status == CheckStatus.warning) ||
      (_doctorResult.value?.issues.any((issue) => issue.severity == 'warning') ?? false);
  bool get hasErrors => _networkResults.any((item) => item.status == CheckStatus.failed) ||
      (_doctorResult.value?.issues.any((issue) => issue.severity == 'error') ?? false) ||
      (_flutterInfo.value?.isInstalled == false) ||
      (_androidInfo.value?.isConfigured == false);

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  void _initializeServices() {
    _networkService = Get.find<NetworkService>();
    _flutterService = Get.find<FlutterService>();
    _androidService = Get.find<AndroidService>();
  }

  Future<void> runAllChecks() async {
    if (_isRunningChecks.value) return;

    _isRunningChecks.value = true;
    _completedChecks.value = 0;
    _overallProgress.value = 0.0;
    
    try {
      // 1. Network checks
      await _runNetworkChecks();
      _updateProgress();

      // 2. Flutter version check
      await _runFlutterVersionCheck();
      _updateProgress();

      // 3. Flutter doctor
      await _runFlutterDoctorCheck();
      _updateProgress();

      // 4. Flutter upgrade check
      await _runFlutterUpgradeCheck();
      _updateProgress();

      // 5. Pub packages check
      await _runPubPackagesCheck();
      _updateProgress();

      // 6. Android SDK check
      await _runAndroidSdkCheck();
      _updateProgress();

    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during system checks: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isRunningChecks.value = false;
      _currentCheckName.value = '';
    }
  }

  Future<void> _runNetworkChecks() async {
    _currentCheckName.value = 'Testing Network Connectivity';
    
    final results = await _networkService.checkAllUrls(
      onProgress: (item) {
        final index = _networkResults.indexWhere((r) => r.url == item.url);
        if (index != -1) {
          _networkResults[index] = item;
        } else {
          _networkResults.add(item);
        }
      },
    );
    
    _networkResults.assignAll(results);
  }

  Future<void> _runFlutterVersionCheck() async {
    _currentCheckName.value = 'Checking Flutter SDK';
    _flutterInfo.value = await _flutterService.getFlutterVersion();
  }

  Future<void> _runFlutterDoctorCheck() async {
    _currentCheckName.value = 'Running Flutter Doctor';
    _doctorResult.value = await _flutterService.runFlutterDoctor();
  }

  Future<void> _runFlutterUpgradeCheck() async {
    _currentCheckName.value = 'Checking for Flutter Updates';
    _upgradeResult.value = await _flutterService.checkForUpdates();
  }

  Future<void> _runPubPackagesCheck() async {
    _currentCheckName.value = 'Checking Package Dependencies';
    final packages = await _flutterService.checkPubOutdated();
    _pubPackages.assignAll(packages);
  }

  Future<void> _runAndroidSdkCheck() async {
    _currentCheckName.value = 'Checking Android SDK';
    _androidInfo.value = await _androidService.getAndroidSdkInfo();
  }

  void _updateProgress() {
    _completedChecks.value++;
    _overallProgress.value = _completedChecks.value / _totalChecks.value;
  }

  Future<void> retryNetworkCheck(NetworkCheckItem item) async {
    if (_isRunningChecks.value) return;

    final index = _networkResults.indexWhere((r) => r.url == item.url);
    if (index == -1) return;

    // Mark as running
    _networkResults[index] = item.copyWith(status: CheckStatus.running);
    
    // Perform check
    final result = await _networkService.checkUrl(item);
    _networkResults[index] = result;
  }

  Future<void> retryFlutterDoctor() async {
    if (_isRunningChecks.value) return;
    
    _currentCheckName.value = 'Running Flutter Doctor';
    _doctorResult.value = await _flutterService.runFlutterDoctor();
    _currentCheckName.value = '';
  }

  void clearResults() {
    _networkResults.clear();
    _flutterInfo.value = null;
    _doctorResult.value = null;
    _upgradeResult.value = null;
    _pubPackages.clear();
    _androidInfo.value = null;
    _overallProgress.value = 0.0;
    _completedChecks.value = 0;
  }

  String getOverallStatus() {
    if (_isRunningChecks.value) {
      return 'Running checks...';
    }
    
    if (hasErrors) {
      return 'Issues detected - Action required';
    } else if (hasWarnings) {
      return 'Minor issues detected - Review recommended';
    } else if (_completedChecks.value > 0) {
      return 'All checks passed successfully';
    } else {
      return 'Ready to run system checks';
    }
  }
}