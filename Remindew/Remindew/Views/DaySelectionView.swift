//
//  DaySelectionView.swift
//  Remindew
//
//  Created by Jorge Alvarez on 11/24/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class DaySelectionView: UIStackView {

    // MARK: - Properties
    /// Array of Strings just for label purposes
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    static let dayInitials = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    var buttonArray = [UIButton]()
    
    // MARK: - View Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init with frame")
        setupSubviews()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        print("init with coder")
        setupSubviews()
    }
    
    @objc private func selectDay(_ button: UIButton) {
        print("tapped button \(button.tag)")
        if button.backgroundColor == .clear {
            button.backgroundColor = .waterBlue
            button.tintColor = .white
        } else {
            button.backgroundColor = .clear
            button.tintColor = .waterBlue
        }
    }
    
    private func setupSubviews() {
        
        distribution = .fillEqually
        self.spacing = 4
        for integer in 0..<days.count {
            let day = UIButton(type: .system)
            day.translatesAutoresizingMaskIntoConstraints = false
            addArrangedSubview(day)
            buttonArray.append(day)
            day.tag = integer + 1
            day.contentMode = .scaleToFill
//            day.frame = CGRect(x: 0,
//                                y: 0,
//                                width: 20.0,
//                                height: 50.0)
            day.setTitle("\(days[integer])", for: .normal)
            day.backgroundColor = .clear
            
            day.tintColor = .waterBlue
            
            // Change to this later for new underline look
//            day.tintColor = .lightGray
//
//            if day.tag % 2 == 0 {
//                day.tintColor = .waterBlue
//                day.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
//            }
            
            day.addTarget(self, action: #selector(selectDay), for: .touchUpInside)
            
            print("SELF.FRAME.HEIGHT = \(self.frame.height) / 2 = \(self.frame.height / 2.5)")
//            day.layer.cornerRadius = self.frame.height / 2.5 // used to be 15.0
            day.layer.cornerRadius = 13.0

//            day.layer.borderWidth = 2.0
//            day.layer.borderColor = UIColor.mixedBlueGreen.cgColor
        }
    }
    
    /// Sets buttons to selected
    func selectDays(_ daysToSelect: [Int16]) {
        print("selectDays called")
        for day in daysToSelect {
            let index = Int(day) - 1
            print("day = \(day) index = \(index)")
            selectDay(buttonArray[index])
        }
//        selectDay(buttonArray[index])
    }
    
    /// Return an array of Int16s that are currently selected (Sunday = 1, etc)
    func returnDaysSelected() -> [Int16] {
        var result = [Int16]()
        for button in buttonArray {
            // if "selected"
            if button.backgroundColor == UIColor.waterBlue {
                print("Selected: \(button.titleLabel?.text ?? "no title")")
                result.append(Int16(button.tag))
            }
        }
        // array of selected day buttons
//        let tempResult = buttonArray.filter { $0.backgroundColor == UIColor.waterBlue }
        
        print("days selected: \(result)")
        // return first thing in this array (will crash right now if none are selected)
        return result //Int16(result[0].tag)
    }
}
