//
//  ScreenshotLocationTests.swift
//  Screenshot2Clipboard
//
//  Standalone checks for the pure ScreenshotLocation logic. Compiles the real
//  source (no duplication), so no Xcode test target is needed. Run:
//
//    swiftc Screenshot2Clipboard/ScreenshotLocation.swift Screenshot2ClipboardTests/ScreenshotLocationTests.swift \
//        -o "$TMPDIR/s2c-tests" && "$TMPDIR/s2c-tests"
//

import Foundation

@main
enum ScreenshotLocationTests {
	static func main() {
		let home = URL(fileURLWithPath: "/Users/test", isDirectory: true)

		// Falls back to ~/Desktop when com.apple.screencapture has no location.
		let empty = UserDefaults(suiteName: "by.ayoo.screenshot2clipboard.tests.empty")!
		empty.removeObject(forKey: "location")
		check(ScreenshotLocation.resolve(screencaptureDefaults: empty, home: home).path == "/Users/test/Desktop",
			  "defaults to ~/Desktop when no location is set")

		// Honours an explicit location.
		let custom = UserDefaults(suiteName: "by.ayoo.screenshot2clipboard.tests.custom")!
		custom.set("/Users/test/Pictures/Screenshots", forKey: "location")
		check(ScreenshotLocation.resolve(screencaptureDefaults: custom, home: home).path == "/Users/test/Pictures/Screenshots",
			  "honours an explicit location")

		// Expands a leading tilde against the given home, not the process's own
		// (which, under the App Sandbox, is the container).
		let tilde = UserDefaults(suiteName: "by.ayoo.screenshot2clipboard.tests.tilde")!
		tilde.set("~/Pictures/Screenshots", forKey: "location")
		check(ScreenshotLocation.resolve(screencaptureDefaults: tilde, home: home).path == "/Users/test/Pictures/Screenshots",
			  "expands a leading tilde against the given home")
		check(ScreenshotLocation.expandTilde("~", home: home) == "/Users/test",
			  "a bare tilde is the home itself")
		check(ScreenshotLocation.expandTilde("/tmp/shots", home: home) == "/tmp/shots",
			  "an absolute path passes through untouched")

		// isInsidePictures: true for ~/Pictures and below, false elsewhere.
		check(ScreenshotLocation.isInsidePictures(URL(fileURLWithPath: "/Users/test/Pictures/Screenshots", isDirectory: true), home: home),
			  "~/Pictures/Screenshots is inside Pictures")
		check(ScreenshotLocation.isInsidePictures(URL(fileURLWithPath: "/Users/test/Pictures", isDirectory: true), home: home),
			  "~/Pictures itself is inside Pictures")
		check(!ScreenshotLocation.isInsidePictures(URL(fileURLWithPath: "/Users/test/Desktop", isDirectory: true), home: home),
			  "~/Desktop is not inside Pictures")
		check(!ScreenshotLocation.isInsidePictures(URL(fileURLWithPath: "/Users/test/PicturesElsewhere", isDirectory: true), home: home),
			  "a sibling folder prefixed 'Pictures' is not inside Pictures")

		empty.removePersistentDomain(forName: "by.ayoo.screenshot2clipboard.tests.empty")
		custom.removePersistentDomain(forName: "by.ayoo.screenshot2clipboard.tests.custom")
		tilde.removePersistentDomain(forName: "by.ayoo.screenshot2clipboard.tests.tilde")
		print("ok: all ScreenshotLocation checks passed")
	}

	static func check(_ condition: Bool, _ name: String) {
		if condition {
			print("pass: \(name)")
		} else {
			FileHandle.standardError.write(Data("FAIL: \(name)\n".utf8))
			exit(1)
		}
	}
}
