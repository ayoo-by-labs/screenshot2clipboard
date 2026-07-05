//
//  ObserverDelegate.swift
//  Screenshot2Clipboard
//
//  Created by Diab Neiroukh on 2024-07-04.
//

import Cocoa

class ObserverDelegate: NSObject, ScreenShotObserverDelegate {
	let observer: ScreenShotObserver

	override init() {
		let paths = ScreenshotLocation.authorizedFolder().map { [$0.path] } ?? []
		observer = ScreenShotObserver(searchDirectoryPaths: paths)
		super.init()
	}

	func screenShotObserver(_ observer: ScreenShotObserver, addedItem imageMetadata: NSMetadataItem) {
		copyScreenshot(imageMetadata, event: "added")
	}

	func screenShotObserver(_ observer: ScreenShotObserver, updatedItem imageMetadata: NSMetadataItem) {
		copyScreenshot(imageMetadata, event: "updated")
	}

	// Copies a freshly captured screenshot onto the clipboard. A new screenshot
	// first arrives as an ADDED item (and may later re-fire as a CHANGED one), so
	// both callbacks route here. The clipboard is cleared only once the bitmap has
	// loaded, so an unreadable capture — e.g. a screen recording's .mov, which
	// also carries kMDItemIsScreenCapture = 1 — never wipes what the user copied.
	private func copyScreenshot(_ imageMetadata: NSMetadataItem, event: String) {
		guard let path = imageMetadata.value(forAttribute: NSMetadataItemPathKey) as? String else {
			return
		}

		#if DEBUG
		NSLog("[ObserverDelegate/copyScreenshot()] The screenshot at, \(path), was \(event).")
		#endif

		guard let tiff = NSImage(contentsOfFile: path)?.tiffRepresentation else {
			return
		}

		let clipboard = NSPasteboard.general
		clipboard.clearContents()
		clipboard.setData(tiff, forType: .tiff)
	}
}
