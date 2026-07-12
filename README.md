# Screenshot2Clipboard

A macOS menu-bar app that copies each new screenshot to the clipboard the moment you take it. Paste it straight into a document or chat without opening the file first.

It has no Dock icon or window and lives entirely in the menu bar, watching for new screen captures.

## How It Works

macOS saves screenshots to `~/Desktop` by default, or to the folder set with `defaults write com.apple.screencapture location`. Screenshot2Clipboard reads that setting and watches the matching folder with a Spotlight query for screen captures, then copies each new one to the clipboard as an image.

The app is sandboxed and cannot read arbitrary folders. If your screenshots land in `~/Pictures`, it reads them directly. Otherwise it asks once, on first launch, for access to the folder, then remembers the grant across launches with a security-scoped bookmark.

The app skips a capture it cannot read as an image, such as a screen recording (which macOS also tags as a screen capture), so the clipboard keeps whatever you already had.

## Menu

- About: attribution and licence.
- Quit.

## Build

Open `Screenshot2Clipboard.xcodeproj` in Xcode and run, or build from the command line:

```
xcodebuild -project Screenshot2Clipboard.xcodeproj -scheme Debug build
```

Requires macOS 13 or later.

## Attribution

Screenshot detection uses [Screeen](https://github.com/Clipy/Screeen) from the Clipy project, under the MIT licence. See `Credits.html` and `Screenshot2Clipboard/Utilities/Screeen/LICENSE`.

## Licence

[PolyForm Noncommercial 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0), Copyright 2024-2026 Ayooby (https://ayoo.by) — free for noncommercial use. The vendored Screeen library remains under its own MIT licence. See `LICENSE`.
