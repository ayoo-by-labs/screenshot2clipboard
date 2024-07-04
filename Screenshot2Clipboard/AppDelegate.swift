//
//  AppDelegate.swift
//  Screenshot2Clipboard
//
//  Created by Diab Neiroukh on 2024-07-04.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    let observerDelegate = ObserverDelegate()
    let menuDelegate = MenuDelegate()
    lazy var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

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

    func buildObserver() {
        self.observerDelegate.observer.delegate = self.observerDelegate
        self.observerDelegate.observer.start()
    }
}
