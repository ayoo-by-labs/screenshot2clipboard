//
//  ObserverDelegate.swift
//  Screenshot2Clipboard
//
//  Created by Diab Neiroukh on 2024-07-04.
//

import Cocoa
import UniformTypeIdentifiers

class ObserverDelegate: NSObject, ScreenShotObserverDelegate {
	// Nil when the user declined folder access: Screeen treats an empty scope
	// list as "search everywhere", which would watch folders the user refused
	// to share, so no folder means no observer at all.
	let observer: ScreenShotObserver?

	private var lastCopied: (path: String, created: Date)?

	override init() {
		observer = ScreenshotLocation.authorizedFolder().map {
			ScreenShotObserver(searchDirectoryPaths: [$0.path])
		}
		super.init()
	}

	func screenShotObserver(_ observer: ScreenShotObserver, addedItem imageMetadata: NSMetadataItem) {
		copyScreenshot(imageMetadata, event: "added")
	}

	func screenShotObserver(_ observer: ScreenShotObserver, updatedItem imageMetadata: NSMetadataItem) {
		copyScreenshot(imageMetadata, event: "updated")
	}

	// Whether a fresh capture arrives as an added or a changed item varies with
	// how it was written (temp-file rename versus direct write) and with whether
	// the query was still gathering, so both callbacks route here. The freshness
	// gate stops metadata churn on old screenshots (opening one in Preview
	// updates its last-used date, which fires a changed item) from clobbering
	// the clipboard with a stale image, and the (path, creation date) pair keeps
	// the added/changed double-fire from copying twice without blocking a fresh
	// capture written to a reused path.
	private func copyScreenshot(_ imageMetadata: NSMetadataItem, event: String) {
		guard let imagePath = imageMetadata.value(forAttribute: NSMetadataItemPathKey) as? String,
		      let created = imageMetadata.value(forAttribute: NSMetadataItemFSCreationDateKey) as? Date,
		      Date().timeIntervalSince(created) < 30,
		      lastCopied?.path != imagePath || lastCopied?.created != created else {
			return
		}

		#if DEBUG
		NSLog("[ObserverDelegate/copyScreenshot()] The Screenshot at, \(imagePath), was \(event).")
		#endif

		// Load before clearing, so a capture that is not a readable image (a
		// screen recording's .mov also carries kMDItemIsScreenCapture = 1)
		// never wipes what the user had on the clipboard.
		guard let image = NSImage(contentsOfFile: imagePath) else {
			return
		}

		lastCopied = (imagePath, created)

		// Publish the file's own bytes under its real type (a PNG stays a PNG),
		// plus a TIFF fallback from the decoded image so any target gets
		// something — writeObjects([NSImage]) alone re-encodes every capture to
		// a bulky TIFF and drops targets that only take PNG (web fields, some
		// Electron apps).
		let item = NSPasteboardItem()
		if let type = UTType(filenameExtension: (imagePath as NSString).pathExtension)?.identifier,
		   let data = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) {
			item.setData(data, forType: NSPasteboard.PasteboardType(type))
		}
		if let tiff = image.tiffRepresentation {
			item.setData(tiff, forType: .tiff)
		}

		let clipboard = NSPasteboard.general
		clipboard.clearContents()
		clipboard.writeObjects([item])
	}
}
