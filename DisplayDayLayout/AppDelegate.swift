//
//  AppDelegate.swift
//  DisplayDayLayout
//
//  Created by Maksym Stobetskyi on 9/18/17.
//  Copyright © 2017 Readdle. All rights reserved.
//

import Cocoa

let hour = TimeInterval(3600)
let width = CGFloat(400)

let colors = [
    "1": NSColor.black,
    "2": NSColor.red,
    "3": NSColor.green,
    "4": NSColor.blue,
    "5": NSColor.gray,
    "6": NSColor.cyan,
    "7": NSColor.yellow,
    "8": NSColor.magenta,
    "9": NSColor.orange,
    "10": NSColor.darkGray,
    "11": NSColor.purple,
    "12": NSColor.brown
]

func getSampleLayouts() -> [[CalendarLayoutItem]] {
    let l1 = [
        CalendarLayoutItem(start: 0, duration: hour * 9, identifier: "1"),
        CalendarLayoutItem(start: 0, duration: hour * 15, identifier: "2"),
        CalendarLayoutItem(start: hour * 14, duration: hour * 1, identifier: "3"),
        CalendarLayoutItem(start: hour * 14, duration: hour * 1, identifier: "5"),
        CalendarLayoutItem(start: hour * 6, duration: hour * 2, identifier: "6"),
        CalendarLayoutItem(start: hour * 6, duration: hour * 2, identifier: "7")
    ]
    let l2 = [
        CalendarLayoutItem(start: 0, duration: hour * 9, identifier: "1"),
        CalendarLayoutItem(start: 0, duration: hour * 5, identifier: "2"),
        CalendarLayoutItem(start: hour * 8, duration: hour * 6, identifier: "3")
    ]
    let l3 = [
        CalendarLayoutItem(start: 0, duration: hour * 9, identifier: "1"),
        CalendarLayoutItem(start: 0, duration: hour * 5, identifier: "2"),
        CalendarLayoutItem(start: hour * 6, duration: hour * 2, identifier: "3"),
        CalendarLayoutItem(start: hour * 6, duration: hour * 2, identifier: "4")
    ]
    let l4 = [
        CalendarLayoutItem(start: 0, duration: hour * 9, identifier: "1"),
        CalendarLayoutItem(start: 0, duration: hour * 5, identifier: "2"),
        CalendarLayoutItem(start: hour * 6, duration: hour * 2, identifier: "3"),
        CalendarLayoutItem(start: hour * 4, duration: hour * 3, identifier: "4")
    ]
    return [l1, l2, l3, l4]
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let screenFrame = NSScreen.main()!.frame
        window.setFrame(screenFrame, display: true)
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.white.cgColor
        
        for layoutItemsEnum in getSampleLayouts().enumerated() {
            let rootView = NSFlippedView(frame: CGRect(x: CGFloat(layoutItemsEnum.offset) * (width + 10.0), y: 0, width: (width + 10.0), height: screenFrame.height))
            window.contentView?.addSubview(rootView)
            
            let rootItem = CalendarLayoutItem.defaultRootItem()
            rootItem.hourHeight = screenFrame.height / 24
            rootItem.processItems(layoutItemsEnum.element)
            
            let frames = rootItem.framesForWidth(width)
            for f in frames {
                let v = NSView(frame: f.value)
                v.wantsLayer = true
                v.layer?.backgroundColor = colors[f.key]?.cgColor.copy(alpha: 0.5)
                rootView.addSubview(v)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

