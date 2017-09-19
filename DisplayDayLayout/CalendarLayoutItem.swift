//
//  File.swift
//  SmartMail
//
//  Created by Mikhail Pashnyov on 2/13/17.
//  Copyright © 2017 Readdle. All rights reserved.
//

import Foundation
import CoreGraphics


@objc public class CalendarLayoutItem: NSObject {

    fileprivate static let MinutesSnap:Double = 5.0 * 60.0
    fileprivate static let MinOffset:TimeInterval = MinutesSnap * 3.0
    fileprivate static let MinHeight:TimeInterval = 30 * 60

    
    fileprivate struct Span {
        static let Left :CGFloat = 8.0
        static let Right:CGFloat = 2.0
    }

    fileprivate let startTime   :TimeInterval
    fileprivate let endTime     :TimeInterval


    public let identifier: String
    public let isPreferredItem: Bool
    public var hourHeight: CGFloat = 1.0
    public var processedItems = [CalendarLayoutItem]()
    
    fileprivate var childs = [CalendarLayoutItem]()
    fileprivate var parentNote:CalendarLayoutItem? = nil

    fileprivate var duration  :TimeInterval {
        return endTime - startTime
    }

    fileprivate var allowIntersections:Bool {
        return !isPreferredItem
    }

    fileprivate var subnodesEnd :TimeInterval {
        return childs.reduce(endTime) { max($0.0, $0.1.subnodesEnd) }
    }

    public init(start:TimeInterval, end:TimeInterval, identifier:String, preferred:Bool = false) {
        self.identifier = identifier
        self.isPreferredItem = preferred
        self.startTime = start
        self.endTime = max(end, start + 15 * 60.0)
    }
    
    public convenience init(start:TimeInterval, duration: TimeInterval, identifier:String, preferred:Bool = false) {
        self.init(start: start, end:start + duration, identifier:identifier, preferred:preferred)
    }
    
    @objc public func copy(_ zone: NSZone? = nil) -> Any {
        let item = CalendarLayoutItem(start:startTime, end:endTime, identifier: identifier, preferred:self.isPreferredItem)
        return item;
    }

    public static func defaultRootItem() -> CalendarLayoutItem {
        return CalendarLayoutItem(start:TimeInterval.leastNormalMagnitude, end:TimeInterval.greatestFiniteMagnitude, identifier:"root")
    }
}
extension CalendarLayoutItem {
    
    fileprivate func snapTimeinterval(_ time:TimeInterval, snap:Double) -> TimeInterval {
        return round(time / snap) * snap
    }
    
    fileprivate var displayStart : TimeInterval {
        return snapTimeinterval(startTime, snap: CalendarLayoutItem.MinutesSnap)
    }
    
    fileprivate var displayEnd : TimeInterval {
        return snapTimeinterval(endTime, snap: CalendarLayoutItem.MinutesSnap)
    }
    
    fileprivate var displayDuration : TimeInterval {
        return max(displayEnd, displayStart + CalendarLayoutItem.MinHeight) - displayStart
    }
    
    fileprivate var displaySubnodesEnd : TimeInterval {
        return snapTimeinterval(subnodesEnd, snap: CalendarLayoutItem.MinutesSnap)
    }
    
    public var firstChildStarstInTooClose : Bool {
        return (self.childs.reduce(TimeInterval.greatestFiniteMagnitude) { min($0.0, $0.1.displayStart) } - self.displayStart) <= 30.0 * 60.0
    }
}

extension CalendarLayoutItem {

    public func processItems(_ items:[CalendarLayoutItem]?) {
        guard let itemsToLayout = items else {
            return
        }
        processedItems.removeAll()
        itemsToLayout.forEach {
            insert($0, force: true)
        }
        processedItems.append(contentsOf: itemsToLayout)
    }

    fileprivate func canInsert(_ otherNode:CalendarLayoutItem) -> Bool {

        guard otherNode.allowIntersections && self.allowIntersections else {
            return false
        }

        if (otherNode.displayStart <= displayStart) {
            return false
        }
        if otherNode.displayStart + 1.0 >= displaySubnodesEnd {
            return false
        }

        if  max(0, otherNode.displayStart) <= max(0, displayStart) + CalendarLayoutItem.MinOffset {// span
            return false
        }

        for item in childs {
            if item.canInsert(otherNode) {
                return true
            }
        }
        return true
    }
    
    fileprivate func numberOfChildIntersections(_ otherNode:CalendarLayoutItem) -> Int {
        let intersectsMe = self.startTime < otherNode.endTime && self.endTime > otherNode.startTime;
        if intersectsMe == false {
            return 0
        }
        let numberOfIntersectionsInChild = childs.reduce(1) { result, child in
            return result + child.numberOfChildIntersections(otherNode)
        }
        return numberOfIntersectionsInChild
    }

    fileprivate func insert(_ otherNode:CalendarLayoutItem, force:Bool = false) {

        if !canInsert(otherNode) && !force {
            return
        }

        let possibleChilds = childs
            .filter { $0.canInsert(otherNode) }
            .sorted { $0.0.numberOfChildIntersections(otherNode) < $0.1.numberOfChildIntersections(otherNode) }

        if let lessHeavyNode = possibleChilds.first {
            lessHeavyNode.insert(otherNode)
            return
        }

        otherNode.parentNote = self
        childs.append(otherNode)
        childs.sort {
            if ($0.0.startTime == $0.1.startTime) {
                return $0.0.duration < $0.1.duration
            }
            return $0.0.startTime < $0.1.startTime
        }
    }

    fileprivate func remove(item: CalendarLayoutItem) {
        if let index = childs.index(where: { $0 == item }) {
            childs.remove(at: index)
        }
    }
}

extension CalendarLayoutItem {

    typealias FrameInfo = (identifier: String, frame: CGRect)


    fileprivate func printPretty(_ indent:String,
                          last:Bool = false) -> String {
        var toPrint = indent
        var newIndent = indent
        if last {
            toPrint   += "\\-";
            newIndent += "  ";
        }
        else {
            toPrint    += "|-";
            newIndent  += "| ";
        }
        toPrint += "\(self.className) [\(startTimeString)-\(endTimeString)] -\(identifier)"
        toPrint.append("\n")
        for i in 0..<self.childs.count {
            toPrint.append(childs[i].printPretty(newIndent, last: i == self.childs.count - 1))
        }
        return toPrint
    }

    open func framesForWidth(_ width:CGFloat) -> [String:CGRect] {
        let frames = self.childFrames(x: 0, width: width, minuteHeight: Double(self.hourHeight) / 60.0)
        var retValue = [String:CGRect]()
        frames.forEach { curretItem in
            let framesWithoutCurrentItem = frames.filter{$0.identifier != curretItem.identifier}
            var maxX = width

            framesWithoutCurrentItem.forEach {
                if $0.frame.minY >= curretItem.frame.maxY || $0.frame.maxY <= curretItem.frame.minY {
                    return
                }

                if $0.frame.minX >= curretItem.frame.maxX {
                    maxX = min($0.frame.minX, maxX)
                }
            }
            var frame = curretItem.frame
            frame.size.width = maxX - curretItem.frame.minX
            retValue[curretItem.identifier] = frame
        }

        return retValue
    }

    fileprivate func displayFrame(x:CGFloat,
                                  width:CGFloat,
                                  minuteHeight:Double) -> FrameInfo {
        var frame:CGRect = .zero
        frame.origin.x = x
        frame.size.width = width
        frame.size.height = CGFloat(minuteHeight * displayDuration / 60.0)
        frame.origin.y = CGFloat(displayStart / 60 * minuteHeight)
        return (self.identifier, frame)
    }

    fileprivate func childFrames(x:CGFloat,
                                 width:CGFloat,
                                 minuteHeight:Double) -> [FrameInfo] {
        var startX = x
        var leftWidth = width
        var retValue = [FrameInfo]()
        let layoutGroups = layoutGroupsInItems(childs)


        if let singleItem = (childs.filter{ !$0.allowIntersections}.first) {
            let frameInfo = singleItem.displayFrame(x: x, width: width * 0.3, minuteHeight: minuteHeight)
            retValue.append(frameInfo)
            startX = x + frameInfo.1.width
            leftWidth = width - frameInfo.1.width
        }
        for group in layoutGroups {
            let groupWidth = leftWidth / CGFloat(group.count)
            group.enumerated()
                .forEach({ (offset: Int, item: CalendarLayoutItem) in
                    let parentInfo = item.displayFrame(x: startX + groupWidth * CGFloat(offset),
                                                       width: groupWidth,
                                                       minuteHeight: minuteHeight)

                    let childsInfo = item.childFrames(x: parentInfo.1.minX + Span.Left,
                                                      width: parentInfo.1.width - Span.Left - Span.Right,
                                                      minuteHeight: minuteHeight)
                    retValue.append(parentInfo)
                    retValue.append(contentsOf:childsInfo)
                })
        }
        return retValue
    }

    fileprivate func layoutGroupsInItems(_ items:[CalendarLayoutItem]) -> [[CalendarLayoutItem]] {
        var groups = [[CalendarLayoutItem]]()
        var end   = Double.leastNormalMagnitude
        var group = [CalendarLayoutItem]()
        items.filter { $0.allowIntersections }
            .forEach { element in
                if element.displayStart + 1 > end {
                    groups.append(group)
                    group = [CalendarLayoutItem]()
                }
                group.append(element)
                end = max(element.displaySubnodesEnd, end)
        }
        groups.append(group)

        return groups
            .map { $0.sorted { (a:CalendarLayoutItem, b:CalendarLayoutItem) -> Bool in
                if b.childs.count == a.childs.count {
                    return b.duration < a.duration
                }
                return a.childs.count > b.childs.count
                } }
            .filter { $0.count > 0 }
    }
}

extension CalendarLayoutItem  {
    fileprivate var startTimeString:String {
        if identifier != "root" {
            let h = Int(startTime/3600)
            let m = (Int(startTime) - h*3600)/60
            return "\(h):\(m)"
        }
        return "["
    }

    fileprivate var endTimeString:String {
        if identifier != "root" {
            let h = Int(endTime/3600)
            let m = (Int(endTime) - h*3600)/60
            return "\(h):\(m)"
        }
        return "]"
    }

    public override var debugDescription: String {
        return "(\(startTimeString), end:\(endTimeString))"
    }
}

infix operator <> : MultiplicationPrecedence
extension CalendarLayoutItem {

    fileprivate static func ==(lhs: CalendarLayoutItem, rhs: CalendarLayoutItem) -> Bool {
        return lhs.identifier == rhs.identifier
            && lhs.startTime == rhs.startTime
            && lhs.duration == rhs.duration
    }

    fileprivate static func intersection(_ lhs: CalendarLayoutItem,_ rhs: CalendarLayoutItem) -> TimeInterval {
        let earlierItem = lhs.displayStart < rhs.displayStart ? lhs : rhs
        let laterItem   = lhs.displayStart < rhs.displayStart ? rhs : lhs
        return min(earlierItem.subnodesEnd, laterItem.subnodesEnd) - laterItem.displayStart
    }
    
    fileprivate static func <>(lhs: CalendarLayoutItem, rhs: CalendarLayoutItem) -> Bool {
        return intersection(lhs,rhs) >= 0
    }
}
