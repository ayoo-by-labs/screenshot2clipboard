#! /usr/bin/env bash
# Compiles Screenshot2Clipboard's pure ScreenshotLocation logic together with the
# standalone checks and runs them. These test the shipping source directly,
# without an Xcode test target. ScreenshotLocation has no #if DEBUG behaviour, so
# a single build variant covers it.
set -euo pipefail
cd "$(dirname "$0")/.."
out="${TMPDIR:-/tmp}/screenshot2clipboard-tests"
swiftc \
	Screenshot2Clipboard/ScreenshotLocation.swift \
	Screenshot2ClipboardTests/ScreenshotLocationTests.swift \
	-o "$out"
"$out"
