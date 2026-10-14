#!/bin/zsh
set -euo pipefail
task_source="${0:A:h}"
task_output="${1:-$task_source/dist/鼠标语音侧键助手.app}"
task_build="$task_source/.build"

[[ "$(/usr/bin/uname -s)" == Darwin ]] || { print -u2 'Build this application on macOS.'; exit 1; }
mkdir -p "$task_build" "$task_output/Contents/MacOS"
for task_arch in arm64 x86_64; do
  /usr/bin/xcrun clang -O2 -Wall -Wextra -Werror -fobjc-arc \
    -target "$task_arch-apple-macos11.0" -framework Cocoa -framework ApplicationServices \
    "$task_source/Sources/main.m" -o "$task_build/MouseVoiceButtons-$task_arch"
done
/usr/bin/lipo -create "$task_build/MouseVoiceButtons-arm64" "$task_build/MouseVoiceButtons-x86_64" \
  -output "$task_output/Contents/MacOS/MouseVoiceButtons"
cp "$task_source/Info.plist" "$task_output/Contents/Info.plist"
/usr/bin/codesign --force --sign - "$task_output"
/usr/bin/codesign --verify --strict "$task_output"
print "Built: $task_output"
