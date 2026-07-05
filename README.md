# Screenshot2Clipboard

Puts every new screenshot on the clipboard the moment you take it, so you can paste straight away with no manual copy step.

A menu-bar app — no Dock icon, no window. It watches the folder macOS saves screenshots to and copies each new capture onto the clipboard as an image.

## How it works

macOS saves screenshots to `~/Desktop` by default, or wherever you point `defaults write com.apple.screencapture location`. Screenshot2Clipboard watches that folder with a Spotlight query for screen captures and copies each new one.

The app is sandboxed, so it cannot read arbitrary folders on its own. Unless your screenshots already land in `~/Pictures`, it asks — once, on first run — for access to your screenshots folder, then remembers the grant across launches with a security-scoped bookmark.

An unreadable capture (for example a screen recording, which macOS also tags as a screen capture) is skipped, so it never clears what you already had on the clipboard.

## Menu

- About — attribution and licence.
- Quit.

## Build

Open `Screenshot2Clipboard.xcodeproj` in Xcode and run, or:

```
xcodebuild -project Screenshot2Clipboard.xcodeproj -scheme Debug build
```

Requires macOS 11 or later.

## Attribution

Screenshot detection uses [Screeen](https://github.com/Clipy) from the Clipy project (MIT). See `Credits.html` and `Screenshot2Clipboard/Utilities/Screeen/LICENSE`.

## Licence

Proprietary — all rights reserved. See `LICENSE`.
