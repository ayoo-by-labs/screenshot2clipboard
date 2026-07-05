//
//  MenuDelegate.swift
//  Screenshot2Clipboard
//
//  Created by Diab Neiroukh on 2024-07-04.
//

import Cocoa

class MenuDelegate: NSObject, NSMenuDelegate {
	let menu = NSMenu()

	func menuNeedsUpdate(_ menu: NSMenu) {
		menu.removeAllItems()

		menu.addItem(NSMenuItem(
			title: "About",
			action: #selector(selectorAbout),
			keyEquivalent: ""))

		menu.addItem(NSMenuItem.separator())

		menu.addItem(NSMenuItem(
			title: "Quit",
			action: #selector(selectorQuit),
			keyEquivalent: "q"))

		for item in menu.items {
			item.target = self
		}
	}

	@objc func selectorAbout(sender: NSMenuItem) {
		NSApp.orderFrontStandardAboutPanel()
	}

	@objc func selectorQuit(sender: NSMenuItem) {
		NSApp.terminate(self)
	}
}
