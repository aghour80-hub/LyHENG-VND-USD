#!/usr/bin/env bash
# Script tự động tải Flutter SDK và build Web trên Render.com
set -e

echo "=== BẮT ĐẦU BUILD FLUTTER WEB TRÊN RENDER ==="

FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "-> Đang tải Flutter SDK (Stable)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
else
  echo "-> Flutter SDK đã có sẵn trong cache."
fi

export PATH="$PATH:$FLUTTER_DIR/bin"

echo "-> Kiểm tra phiên bản Flutter:"
flutter --version

echo "-> Tải dependencies..."
flutter pub get

echo "-> Biên dịch Flutter Web Release..."
flutter build web --release --no-tree-shake-icons

echo "=== BUILD HOÀN TẤT THÀNH CÔNG ==="
