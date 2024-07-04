//
//  ObserverDelegate.swift
//  Screenshot2Clipboard
//
//  Created by Diab Neiroukh on 2024-07-04.
//

import Cocoa

class ObserverDelegate: NSObject, ScreenShotObserverDelegate {
    let observer = ScreenShotObserver(searchDirectoryPaths: [NSSearchPathForDirectoriesInDomains(.picturesDirectory, .userDomainMask, true).first].compactMap { $0 })

    #if DEBUG
    func screenShotObserver(_ observer: ScreenShotObserver,
                            addedItem imageMetadata: NSMetadataItem) {
        NSLog("[ObserverDelegate/screenShotObserver()] The Screenshot, \(imageMetadata), at, \(imageMetadata.value(forAttribute: NSMetadataItemPathKey) as! String), was added.")
    }
    #endif

    func screenShotObserver(_ observer: ScreenShotObserver,
                            updatedItem imageMetadata: NSMetadataItem) {
        let clipboard = NSPasteboard.general
        let imagePath = imageMetadata.value(forAttribute: NSMetadataItemPathKey) as! String

        #if DEBUG
        NSLog("[ObserverDelegate/screenShotObserver()] The Screenshot, \(imageMetadata), at, \(imagePath), was updated.")
        #endif
        
        clipboard.clearContents()
        clipboard.setData(NSImage(contentsOfFile: imagePath)?.tiffRepresentation, forType: NSPasteboard.PasteboardType.tiff)
    }
}
