//
//  AppDelegate.swift
//  DisplayDayLayout
//
//  Created by Maksym Stobetskyi on 9/18/17.
//  Copyright © 2017 Readdle. All rights reserved.
//

import Cocoa

let hour = TimeInterval(3600)
let widthDefault = CGFloat(100)
let widthWithPreferredItem = CGFloat(200)

let colors = [
    "1": NSColor.red,
    "2": NSColor.white,
    "3": NSColor.green,
    "4": NSColor.blue,
    "5": NSColor.cyan,
    "6": NSColor.yellow,
    "7": NSColor.magenta,
    "8": NSColor.orange,
    "9": NSColor.purple,
    "10": NSColor.brown
]

func getSampleLayouts() -> [[CalendarEvent]] {
    let l1 = [
        CalendarEvent(start: 0, duration: hour * 9, identifier: "1"),
        CalendarEvent(start: 0, duration: hour * 15, identifier: "2"),
        CalendarEvent(start: hour * 14, duration: hour * 1, identifier: "3"),
        CalendarEvent(start: hour * 14, duration: hour * 1, identifier: "4"),
        CalendarEvent(start: hour * 6, duration: hour * 2, identifier: "6"),
        CalendarEvent(start: hour * 6, duration: hour * 2, identifier: "7")
    ]
    let l2 = [
        CalendarEvent(start: 0, duration: hour * 9, identifier: "1"),
        CalendarEvent(start: 0, duration: hour * 5, identifier: "2"),
        CalendarEvent(start: hour * 8, duration: hour * 6, identifier: "3")
    ]
    let l3 = [
        CalendarEvent(start: 0, duration: hour * 9, identifier: "1"),
        CalendarEvent(start: 0, duration: hour * 5, identifier: "2"),
        CalendarEvent(start: hour * 6, duration: hour * 2, identifier: "3"),
        CalendarEvent(start: hour * 6, duration: hour * 2, identifier: "4")
    ]
    let l4 = [
        CalendarEvent(start: 0, duration: hour * 5, identifier: "1"),
        CalendarEvent(start: 0, duration: hour * 9, identifier: "2"),
        CalendarEvent(start: hour * 6, duration: hour * 2, identifier: "3"),
        CalendarEvent(start: hour * 6, duration: hour * 2, identifier: "4")
    ]
    let l5 = [
        CalendarEvent(start: 0, duration: hour * 9, identifier: "1"),
        CalendarEvent(start: 0, duration: hour * 5, identifier: "2"),
        CalendarEvent(start: hour * 6, duration: hour * 2, identifier: "3"),
        CalendarEvent(start: hour * 4, duration: hour * 3, identifier: "4")
    ]
    let l6 = [
        CalendarEvent(start: 0, duration: hour * 9, identifier: "1"),
        CalendarEvent(start: hour * 1, duration: hour * 1, identifier: "2"),
        CalendarEvent(start: hour * 2, duration: hour * 1, identifier: "3"),
        CalendarEvent(start: hour * 6, duration: hour * 2, identifier: "4"),
        CalendarEvent(start: hour * 6, duration: hour * 3, identifier: "5")
    ]
    let l7 = [
        CalendarEvent(start: 0, duration: hour * 9, identifier: "1"),
        CalendarEvent(start: hour * 1, duration: hour * 8, identifier: "2"),
        CalendarEvent(start: hour * 6, duration: hour * 2, identifier: "4"),
        CalendarEvent(start: hour * 6, duration: hour * 3, identifier: "5")
    ]
    return [l1, l2, l3, l4, l5, l6, l7]
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let screenFrame = NSScreen.main()!.frame
        window.setFrame(screenFrame, display: true)
        window.contentView!.wantsLayer = true
        window.contentView!.layer?.backgroundColor = NSColor.white.cgColor
        
        let parentRect = CGRect(x: 0,
                                y: 0,
                                width: screenFrame.width / CGFloat(getSampleLayouts().count) - 10,
                                height: screenFrame.height / 2)
        
        for (index, group) in getSampleLayouts().enumerated() {
            
            let rootView = NSFlippedView(frame: CGRect(x: parentRect.width * CGFloat(index) + CGFloat(index) * 10,
                                                       y: 0,
                                                       width: parentRect.width,
                                                       height: parentRect.height))
            rootView.wantsLayer = true
            rootView.layer?.backgroundColor = NSColor.black.cgColor
            window.contentView?.addSubview(rootView)

            for layoutItem in CalendarLayoutCalculator.calculate(events: group, rect: parentRect) {
                let view = NSView(frame: layoutItem.rect)
                view.wantsLayer = true
                view.layer?.backgroundColor = colors[layoutItem.event.identifier]?.cgColor.copy(alpha: 0.5)
                rootView.addSubview(view)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

