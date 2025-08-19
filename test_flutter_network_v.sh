#!/bin/bash

echo "🔍 Flutter Full Environment & Network Test v3.0"
echo "------------------------------------------------"

# ---- Part 1: Network testing on critical resources ----
echo -e "\n🌐 Step 1: Network Test\n"

# Description:
# This array contains a list of critical URLs required for Flutter and related development tools.
# Each URL points to a resource such as SDKs, package repositories, build tools, or other essential services.
# The script will test network connectivity to each of these endpoints to ensure the development environment can access all necessary resources.

URLS=(
  "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"   # Flutter SDK
  "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip"   # Dart SDK
  "https://services.gradle.org/distributions/gradle-8.7-all.zip"   # Gradle Wrapper
  "https://dl.google.com/dl/android/maven2/com/android/tools/build/gradle/8.0.2/gradle-8.0.2.pom"   # Android Gradle Plugin
  "https://dl.google.com/dl/android/maven2/androidx/core/core/1.10.1/core-1.10.1.pom"   # Google Maven (AndroidX)
  "https://repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.12.0/commons-lang3-3.12.0.pom"   # Maven Central
  "https://pub.dev/api/packages/provider"   # pub.dev packages
  "https://cdn.cocoapods.org/all_pods_versions_0_3_5.txt.gz"   # CocoaPods
  "https://github.com/flutter/flutter"   # GitHub
  "https://marketplace.visualstudio.com/_apis/public/gallery"   # VSCode Marketplace
  "https://dl.google.com/android/repository/sys-img/android/sys-img2-33_r01.zip"   # Android Emulator System Image
  "https://nodejs.org/dist/v20.6.0/node-v20.6.0-x64.msi"   # Node.js
  "https://pub.dev/packages/devtools"   # Flutter DevTools
)

for url in "${URLS[@]}"; do
  echo -n "Testing: $url ... "
  status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$url")
  if [ "$status" == "200" ]; then
    echo "✅ OK (200)"
  else
    echo "❌ FAIL (HTTP $status)"
  fi
done

# ---- Part 2: Flutter SDK & Version Check ----
# 
echo -e "\n⚙️ Step 2: Flutter SDK & Version Check\n"

if command -v flutter >/dev/null 2>&1; then
    echo "Flutter is installed ✅"
    flutter --version
else
    echo "Flutter is NOT installed ❌"
fi

# ---- Part 3: Flutter Doctor ----
echo -e "\n🩺 Step 3: Flutter Doctor\n"

if command -v flutter >/dev/null 2>&1; then
    flutter doctor -v
else
    echo "Flutter command not found. Skipping flutter doctor."
fi

# ---- Part 4: Flutter Upgrade Check ----
echo -e "\n⬆️ Step 4: Flutter Upgrade Check\n"

if command -v flutter >/dev/null 2>&1; then
    echo "Checking for Flutter updates..."
    flutter upgrade --dry-run
else
    echo "Flutter command not found. Cannot check for updates."
fi

# ---- Part 5: Pub Packages Check ----
echo -e "\n📦 Step 5: Pub Packages Check\n"

if command -v flutter >/dev/null 2>&1; then
    echo "Running flutter pub outdated..."
    flutter pub outdated || echo "No pubspec.yaml found or pub get not run."
else
    echo "Flutter command not found. Skipping pub packages check."
fi

# ---- Part 6: Android SDK & Tools Check ----
echo -e "\n🤖 Step 6: Android SDK & Tools Check\n"

if [ -d "$ANDROID_SDK_ROOT" ]; then
    echo "ANDROID_SDK_ROOT is set: $ANDROID_SDK_ROOT ✅"
    echo "Checking installed SDK platforms:"
    ls "$ANDROID_SDK_ROOT/platforms" 2>/dev/null || echo "No platforms found"
    echo "Checking installed build-tools:"
    ls "$ANDROID_SDK_ROOT/build-tools" 2>/dev/null || echo "No build-tools found"
else
    echo "ANDROID_SDK_ROOT not set ❌"
fi

echo -e "\n------------------------------------------------"
echo "🔎 Flutter Full Environment Test Finished"
