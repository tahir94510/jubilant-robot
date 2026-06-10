#!/usr/bin/env bash
# Geliştirme konteyneri / CI yardımcı scripti:
#   Flutter stable SDK'yı ve (opsiyonel) Android SDK komut satırı araçlarını kurar.
# Idempotenttir; tekrar çalıştırmak güvenlidir.
#
# Kullanım:
#   bash tool/setup_flutter.sh            # Flutter + Android SDK
#   WITH_ANDROID=0 bash tool/setup_flutter.sh   # yalnızca Flutter
set -euo pipefail

FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"
ANDROID_SDK="${ANDROID_HOME:-$HOME/android-sdk}"

if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  echo "==> En güncel Flutter stable sürümü çözümleniyor..."
  meta_url="https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"
  archive_url=$(curl -fsSL "$meta_url" | python3 -c '
import json, sys
d = json.load(sys.stdin)
stable_hash = d["current_release"]["stable"]
rel = [r for r in d["releases"]
       if r["hash"] == stable_hash and r.get("dart_sdk_arch", "x64") == "x64"][0]
print(d["base_url"] + "/" + rel["archive"])')
  echo "==> İndiriliyor: $archive_url"
  curl -fSL --retry 3 -o /tmp/flutter.tar.xz "$archive_url"
  mkdir -p "$(dirname "$FLUTTER_HOME")"
  tar -xf /tmp/flutter.tar.xz -C "$(dirname "$FLUTTER_HOME")"
  rm -f /tmp/flutter.tar.xz
fi

export PATH="$FLUTTER_HOME/bin:$PATH"
git config --global --add safe.directory "$FLUTTER_HOME" 2>/dev/null || true
flutter --version
flutter config --no-analytics >/dev/null 2>&1 || true

if [ "${WITH_ANDROID:-1}" = "1" ]; then
  if [ ! -d "$ANDROID_SDK/platform-tools" ]; then
    echo "==> Android SDK cmdline-tools kuruluyor..."
    mkdir -p "$ANDROID_SDK/cmdline-tools"
    curl -fSL --retry 3 -o /tmp/cmdtools.zip \
      "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
    unzip -qo /tmp/cmdtools.zip -d "$ANDROID_SDK/cmdline-tools"
    rm -rf "$ANDROID_SDK/cmdline-tools/latest"
    mv "$ANDROID_SDK/cmdline-tools/cmdline-tools" "$ANDROID_SDK/cmdline-tools/latest"
    rm -f /tmp/cmdtools.zip
  fi
  SDKMANAGER="$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager"
  yes | "$SDKMANAGER" --licenses >/dev/null 2>&1 || true
  # platform-tools + platform yeterli; eksik build-tools'u AGP lisanslar kabul edildiği için kendisi indirir.
  "$SDKMANAGER" --install "platform-tools" "platforms;android-36" >/dev/null
  flutter config --android-sdk "$ANDROID_SDK" >/dev/null
  yes | flutter doctor --android-licenses >/dev/null 2>&1 || true
fi

flutter doctor
echo "==> Kurulum tamam. PATH için: export PATH=\"$FLUTTER_HOME/bin:\$PATH\""
