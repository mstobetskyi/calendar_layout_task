//
//  File.swift
//  SmartMail
//
//  Created by Mikhail Pashnyov on 2/13/17.
//  Copyright © 2017 Readdle. All rights reserved.
//

import Foundation
import CoreGraphics


struct CalendarEvent {
    public let startTime: TimeInterval
    public let endTime: TimeInterval
    public let identifier: String
    
    public init(start: TimeInterval, duration: TimeInterval, identifier: String) {
        self.startTime = start
        self.endTime = start + duration
        self.identifier = identifier
    }

    private var duration: TimeInterval {
        return endTime - startTime
    }
}
