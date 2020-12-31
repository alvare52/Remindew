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
                                        isDisabled: Bool = false,
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
        self.isDisabled = isDisabled
    }
}

///// Creating a new managed object in Core Data
//@discardableResult convenience init(nickname: String,
//                                    species: String,
//                                    water_schedule: Date,
//                                    frequency: [Int16],
//                                    needsWatering: Bool = false,
//                                    lastDateWatered: Date? = nil,
//                                    scientificName: String = "",
//                                    notes: String = "",
//                                    mainTitle: String = "",
//                                    mainMessage: String = "",
//                                    mainAction: String = "",
//                                    location: String = "",
//                                    identifier: UUID = UUID(),
//                                    context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
//    self.init(context: context)
//    self.nickname = nickname
//    self.species = species
//    self.water_schedule = water_schedule
//    self.frequency = frequency
//    self.needsWatering = needsWatering
//    self.lastDateWatered = lastDateWatered
//    self.scientificName = scientificName
//    self.notes = notes
//    self.mainTitle = mainTitle
//    self.mainMessage = mainMessage
//    self.mainAction = mainAction
//    self.location = location
//    self.identifier = identifier
//}
