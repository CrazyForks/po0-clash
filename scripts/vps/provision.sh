#!/usr/bin/env bash
# Provision a Debian build host for po0-clash (codegen, analyze, tests; see verify.sh).
# Toolchain pins follow .github/workflows/build.yaml; see docs/development/build.md.
set -euxo pipefail

TOOLS=/opt/flclash-toolchain
mkdir -p "$TOOLS"

# Gradle alone takes ~6 GB; without swap a parallel test run gets it OOM-killed.
if ! swapon --show | grep -q /swapfile; then
  fallocate -l 8G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates curl wget git unzip xz-utils zip file rsync jq \
  build-essential clang cmake ninja-build pkg-config \
  libgtk-3-dev liblzma-dev libstdc++-12-dev libayatana-appindicator3-dev \
  libkeybinder-3.0-dev python3

# JDK 17 (Temurin)
if [ ! -x "$TOOLS/jdk17/bin/java" ]; then
  curl -fsSL -o /tmp/jdk17.tar.gz \
    "https://api.adoptium.net/v3/binary/latest/17/ga/linux/x64/jdk/hotspot/normal/eclipse"
  mkdir -p "$TOOLS/jdk17"
  tar -xzf /tmp/jdk17.tar.gz -C "$TOOLS/jdk17" --strip-components=1
  rm /tmp/jdk17.tar.gz
fi

# Go 1.26.4 (CI pin)
if [ ! -x "$TOOLS/go/bin/go" ]; then
  curl -fsSL -o /tmp/go.tar.gz https://go.dev/dl/go1.26.4.linux-amd64.tar.gz
  tar -xzf /tmp/go.tar.gz -C "$TOOLS"
  rm /tmp/go.tar.gz
fi

# Rust (toolchain pinned by plugins/rust_api/rust/rust-toolchain.toml)
if [ ! -x "$HOME/.cargo/bin/rustup" ]; then
  curl -fsSL https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal
fi
. "$HOME/.cargo/env"
rustup toolchain install 1.95.0 --profile minimal
rustup target add --toolchain 1.95.0 \
  aarch64-linux-android armv7-linux-androideabi x86_64-linux-android x86_64-unknown-linux-gnu
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android

# Flutter 3.47.1 (CI pin)
if [ ! -x "$TOOLS/flutter/bin/flutter" ]; then
  curl -fsSL -o /tmp/flutter.tar.xz \
    https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.1-stable.tar.xz
  tar -xJf /tmp/flutter.tar.xz -C "$TOOLS"
  rm /tmp/flutter.tar.xz
  git config --global --add safe.directory "$TOOLS/flutter"
fi

# Android SDK + NDK r28c
export ANDROID_HOME="$TOOLS/android-sdk"
if [ ! -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
  mkdir -p "$ANDROID_HOME/cmdline-tools"
  curl -fsSL -o /tmp/cmdline.zip \
    https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip
  unzip -q /tmp/cmdline.zip -d /tmp/cmdline
  mv /tmp/cmdline/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
  rm -rf /tmp/cmdline /tmp/cmdline.zip
fi
export JAVA_HOME="$TOOLS/jdk17"
export PATH="$JAVA_HOME/bin:$PATH"
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null || true
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" \
  "platform-tools" "platforms;android-36" "build-tools;36.0.0" \
  "ndk;28.2.13676358" "cmake;3.22.1"

cat > /etc/profile.d/flclash-toolchain.sh <<EOF
export JAVA_HOME=$TOOLS/jdk17
export ANDROID_HOME=$TOOLS/android-sdk
export ANDROID_SDK_ROOT=$TOOLS/android-sdk
export ANDROID_NDK_HOME=$TOOLS/android-sdk/ndk/28.2.13676358
export PATH=\$HOME/.pub-cache/bin:$TOOLS/flutter/bin:$TOOLS/go/bin:\$HOME/.cargo/bin:$TOOLS/jdk17/bin:$TOOLS/android-sdk/platform-tools:\$PATH
export FLUTTER_SUPPRESS_ANALYTICS=true
EOF

. /etc/profile.d/flclash-toolchain.sh
flutter config --no-analytics --android-sdk "$ANDROID_HOME" --jdk-dir "$JAVA_HOME"
flutter --version
flutter precache --android --linux
go version
java -version
echo PROVISION_DONE
