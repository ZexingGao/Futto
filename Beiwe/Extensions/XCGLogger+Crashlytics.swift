//
//  XCGLogger+Crashlytics.swift
//  XCGLogger
//
//  Created by Michael Sanders on 8/12/15.
//  Copyright 2015 Cerebral Gardens. All rights reserved.
//

import Foundation
import Crashlytics
import XCGLogger

// MARK: - XCGCrashlyticsLogDestination
// - An optional log destination that sends the logs to Crashlytics
open class XCGCrashlyticsLogDestination: BaseQueuedDestination {
    // MARK: - Properties
    /// Option: whether or not to output the date the log was created (Always false for this destination)
    open override var showDate: Bool {
        get {
            return false
        }
        set {
            // ignored, NSLog adds the date, so we always want showDate to be false in this subclass
        }
    }

    // MARK: - Overridden Methods
    /// Print the log to the Apple System Log facility (using NSLog).
    ///
    /// - Parameters:
    ///     - message:   Formatted/processed message ready for output.
    ///
    /// - Returns:  Nothing
    ///
    open override func write(message: String) {
        let args: [CVarArg] = [message]
        withVaList(args) { (argp: CVaListPointer) -> Void in
            CLSLogv("%@", argp)
        }
    }
}
/*
open class XCGCrashlyticsLogDestination: XCGBaseLogDestination {
    public override init(owner: XCGLogger, identifier: String) {
        super.init(owner: owner, identifier: identifier)
        showDate = false
    }

    open var xcodeColors: [XCGLogger.LogLevel: XCGLogger.XcodeColor]? = nil

    open override func output(_ logDetails: XCGLogDetails, text: String) {
        let adjustedText: String
        if let xcodeColor = (xcodeColors ?? owner.xcodeColors)[logDetails.logLevel], owner.xcodeColorsEnabled {
            adjustedText = "\(xcodeColor.format())\(text)\(XCGLogger.XcodeColor.reset)"
        } else {
            adjustedText = text
        }

        let args: [CVarArg] = [adjustedText]
        withVaList(args) { (argp: CVaListPointer) -> Void in
            CLSLogv("%@", argp)
        }
    }
}
*/
