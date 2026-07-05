//
//  ScreenshotLocation.swift
//  Screenshot2Clipboard
//
//  Created by Diab Neiroukh on 2024-07-04.
//

import Cocoa

// Resolves the folder macOS saves screenshots to, and — under the App Sandbox —
// obtains persistent read access to it through a security-scoped bookmark.
enum ScreenshotLocation {
	private static let bookmarkKey = "screenshotFolderBookmark"

	// The folder macOS writes screenshots to: the `location` set via
	// `defaults write com.apple.screencapture location`, else ~/Desktop (the
	// system default). Pure, with injectable inputs so it can be tested.
	static func resolve(
		screencaptureDefaults: UserDefaults? = UserDefaults(suiteName: "com.apple.screencapture"),
		home: URL = FileManager.default.homeDirectoryForCurrentUser
	) -> URL {
		if let location = screencaptureDefaults?.string(forKey: "location"), !location.isEmpty {
			return URL(fileURLWithPath: (location as NSString).expandingTildeInPath, isDirectory: true)
				.standardizedFileURL
		}
		return home.appendingPathComponent("Desktop", isDirectory: true).standardizedFileURL
	}

	// True when `url` is ~/Pictures or a folder beneath it — already reachable
	// with the `assets.pictures.read-only` entitlement, so no bookmark is needed.
	static func isInsidePictures(
		_ url: URL,
		home: URL = FileManager.default.homeDirectoryForCurrentUser
	) -> Bool {
		let pictures = home.appendingPathComponent("Pictures", isDirectory: true).standardizedFileURL.path
		let path = url.standardizedFileURL.path
		return path == pictures || path.hasPrefix(pictures + "/")
	}

	// Returns a folder the sandbox may read screenshots from, starting security-
	// scoped access when a bookmark is used. Order: a folder already inside
	// ~/Pictures needs no grant; else a saved bookmark; else a one-time open
	// panel to obtain the user's consent. Nil when the user declines.
	//
	// ponytail: security-scoped access is held for the process lifetime — a
	// menu-bar app watches until it quits, so a balancing stopAccessing() only
	// earns its keep once watching becomes toggleable.
	static func authorizedFolder(_ defaults: UserDefaults = .standard) -> URL? {
		let folder = resolve()
		if isInsidePictures(folder) {
			return folder
		}
		if let url = resolveBookmark(defaults) {
			_ = url.startAccessingSecurityScopedResource()
			return url
		}
		return promptForFolder(defaultingTo: folder, defaults)
	}

	private static func resolveBookmark(_ defaults: UserDefaults) -> URL? {
		guard let data = defaults.data(forKey: bookmarkKey) else { return nil }
		var isStale = false
		return try? URL(
			resolvingBookmarkData: data,
			options: .withSecurityScope,
			relativeTo: nil,
			bookmarkDataIsStale: &isStale
		)
	}

	// Must run on the main thread (post-launch): shows an NSOpenPanel, then saves
	// a security-scoped bookmark to the chosen folder.
	private static func promptForFolder(defaultingTo folder: URL, _ defaults: UserDefaults) -> URL? {
		let panel = NSOpenPanel()
		panel.message = "Choose the folder Screenshot2Clipboard should watch for new screenshots."
		panel.prompt = "Watch Folder"
		panel.canChooseDirectories = true
		panel.canChooseFiles = false
		panel.allowsMultipleSelection = false
		panel.directoryURL = folder
		NSApp.activate(ignoringOtherApps: true)

		guard panel.runModal() == .OK, let url = panel.url else { return nil }

		if let data = try? url.bookmarkData(
			options: .withSecurityScope,
			includingResourceValuesForKeys: nil,
			relativeTo: nil
		) {
			defaults.set(data, forKey: bookmarkKey)
		}
		_ = url.startAccessingSecurityScopedResource()
		return url
	}
}
