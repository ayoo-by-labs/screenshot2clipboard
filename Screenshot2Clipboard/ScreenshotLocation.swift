//
//  ScreenshotLocation.swift
//  Screenshot2Clipboard
//
//  Created by Diab Neiroukh on 2026-07-05.
//

import Cocoa

// Resolves the folder macOS saves screenshots to, and, under the App Sandbox,
// obtains persistent read access to it through a security-scoped bookmark.
enum ScreenshotLocation {
	private static let bookmarkKey = "screenshotFolderBookmark"

	// The real user home, from the user database. Under the App Sandbox,
	// homeDirectoryForCurrentUser (and tilde expansion) point inside the
	// container, which would misresolve the screenshot folder and defeat
	// the ~/Pictures entitlement check. getpwuid can return NULL (a directory-
	// services hiccup), so fall back to the container home rather than trap —
	// degraded (the ~/Pictures shortcut is lost, the open panel takes over) but
	// alive.
	static let userHome: URL = {
		if let pw = getpwuid(getuid()), let dir = pw.pointee.pw_dir {
			return URL(fileURLWithPath: String(cString: dir), isDirectory: true)
		}
		return URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
	}()

	// The folder macOS writes screenshots to: the `location` set via
	// `defaults write com.apple.screencapture location`, else ~/Desktop (the
	// system default). Pure, with injectable inputs so it can be tested.
	static func resolve(
		screencaptureDefaults: UserDefaults? = UserDefaults(suiteName: "com.apple.screencapture"),
		home: URL = userHome
	) -> URL {
		if let location = screencaptureDefaults?.string(forKey: "location"), !location.isEmpty {
			return URL(fileURLWithPath: expandTilde(location, home: home), isDirectory: true)
				.standardizedFileURL
		}
		return home.appendingPathComponent("Desktop", isDirectory: true).standardizedFileURL
	}

	// True when `url` is ~/Pictures or a folder beneath it, already reachable
	// with the Pictures-folder entitlement, so no bookmark is needed.
	static func isInsidePictures(
		_ url: URL,
		home: URL = userHome
	) -> Bool {
		let pictures = home.appendingPathComponent("Pictures", isDirectory: true).standardizedFileURL.path
		let path = url.standardizedFileURL.path
		return path == pictures || path.hasPrefix(pictures + "/")
	}

	// Expands a leading tilde against the given home, not the sandbox
	// container the Foundation expansion would use.
	static func expandTilde(_ path: String, home: URL) -> String {
		if path == "~" {
			return home.path
		}
		if path.hasPrefix("~/") {
			return home.path + path.dropFirst(1)
		}
		return path
	}

	// Returns a folder the sandbox may read screenshots from, starting security-
	// scoped access when a bookmark is used. Order: a folder already inside
	// ~/Pictures needs no grant; else a saved bookmark, but only while it still
	// matches where macOS saves screenshots — a grant for a folder the user has
	// since moved away from is dropped; else a one-time open panel to obtain
	// the user's consent. Nil when the user declines.
	//
	// ponytail: security-scoped access is held for the process lifetime, since a
	// menu-bar app watches until it quits, so a balancing stopAccessing() only
	// earns its keep once watching becomes toggleable.
	static func authorizedFolder(_ defaults: UserDefaults = .standard) -> URL? {
		let folder = resolve()
		if isInsidePictures(folder) {
			return folder
		}
		if let url = resolveBookmark(defaults) {
			if url.standardizedFileURL.path == folder.path {
				return url
			}
			// The grant no longer matches where macOS saves screenshots —
			// drop it and ask for the current folder instead.
			url.stopAccessingSecurityScopedResource()
			defaults.removeObject(forKey: bookmarkKey)
		}
		return promptForFolder(defaultingTo: folder, defaults)
	}

	// Resolves the saved bookmark and starts security-scoped access, cleaning
	// up a grant that no longer opens and refreshing one that has gone stale.
	private static func resolveBookmark(_ defaults: UserDefaults) -> URL? {
		guard let data = defaults.data(forKey: bookmarkKey) else {
			return nil
		}
		var isStale = false
		guard let url = try? URL(
			resolvingBookmarkData: data,
			options: .withSecurityScope,
			relativeTo: nil,
			bookmarkDataIsStale: &isStale
		), url.startAccessingSecurityScopedResource() else {
			defaults.removeObject(forKey: bookmarkKey)
			return nil
		}
		if isStale {
			saveBookmark(for: url, defaults)
		}
		return url
	}

	// The entitlement grants read-only user-selected access, so the bookmark's
	// scope must be read-only too or creation fails.
	private static func saveBookmark(for url: URL, _ defaults: UserDefaults) {
		if let data = try? url.bookmarkData(
			options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess],
			includingResourceValuesForKeys: nil,
			relativeTo: nil
		) {
			defaults.set(data, forKey: bookmarkKey)
		}
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

		guard panel.runModal() == .OK, let url = panel.url else {
			return nil
		}

		saveBookmark(for: url, defaults)
		_ = url.startAccessingSecurityScopedResource()
		return url
	}
}
