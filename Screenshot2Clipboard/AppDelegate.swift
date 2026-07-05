//
//  AppDelegate.swift
//  Screenshot2Clipboard
//
//  Created by Diab Neiroukh on 2024-07-04.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
	let menuDelegate = MenuDelegate()
	lazy var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
	var observerDelegate: ObserverDelegate?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		self.buildMenu()
		self.buildObserver()
	}

	func buildMenu() {
		self.menuDelegate.menu.delegate = self.menuDelegate
		if let button = self.statusItem.button {
			button.image = NSImage(systemSymbolName: "photo.stack.fill", accessibilityDescription: nil)
		}
		self.statusItem.menu = self.menuDelegate.menu
	}

	// Built after launch (not as a stored property) so the folder-access panel,
	// when needed, runs once NSApp is ready to show it.
	func buildObserver() {
		let observerDelegate = ObserverDelegate()
		observerDelegate.observer.delegate = observerDelegate
		observerDelegate.observer.start()
		self.observerDelegate = observerDelegate
	}
}
