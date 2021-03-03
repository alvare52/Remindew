//
//  Notepad.swift
//  Remindew
//
//  Created by Jorge Alvarez on 3/3/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import Foundation

/// Struct that holds all information given in NotepadViewController
struct NotePad {
    var notes: String = ""
    var mainTitle: String = ""
    var mainMessage: String = ""
    var mainAction: String = NSLocalizedString("Water", comment: "water, default main action")
    var location: String = ""
    var scientificName: String = ""
}
