//
//  Reminder+Convenience.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/31/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation
import CoreData

extension Reminder {
    @discardableResult convenience init(actionName: String,
                                        alarmDate: Date,
                                        frequency: Int16,
                                        identifier: UUID = UUID(),
                                        actionTitle: String? = nil,
                                        actionMessage: String? = nil,
                                        lastDate: Date? = nil,
                                        colorIndex: Int16 = Int16(0),
                                        iconIndex: Int16 = Int16(0),
                                        isEnabled: Bool = true,
                                        notes: String = "",
                                        dateCreated: Date = Date(),
                                        needsCompletion: Bool = false,
                                        lastDatesCompleted: [Date] = [],
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.actionName = actionName
        self.alarmDate = alarmDate
        self.frequency = frequency
        self.identifier = identifier
        self.actionTitle = actionTitle
        self.actionMessage = actionMessage
        self.lastDate = lastDate
        self.colorIndex = colorIndex
        self.iconIndex = iconIndex
        self.isEnabled = isEnabled
        self.notes = notes
        self.dateCreated = dateCreated
        self.needsCompletion = needsCompletion
        self.lastDatesCompleted = lastDatesCompleted
    }
}
