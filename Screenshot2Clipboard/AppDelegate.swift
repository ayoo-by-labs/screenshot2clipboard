//
//  AppDelegate.swift
//  Screenshot2Clipboard
//
//  Created by Diab Neiroukh on 2024-07-04.
//

import Cocoa
import MenuBarKit

class AppDelegate: MenuBarAppDelegate {
	var observerDelegate: ObserverDelegate?

	override var statusItemImage: NSImage? {
		NSImage(systemSymbolName: "photo.stack.fill", accessibilityDescription: nil)
	}

	// Built after launch (not as a stored property) so the folder-access panel,
	// when needed, runs once NSApp is ready to show it. A declined panel means
	// no observer, so there is nothing to start.
	override func applicationReady() {
		let observerDelegate = ObserverDelegate()
		observerDelegate.observer?.delegate = observerDelegate
		observerDelegate.observer?.start()
		self.observerDelegate = observerDelegate
	}
}
