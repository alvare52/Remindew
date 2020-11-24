//
//  DaySelectionView.swift
//  Remindew
//
//  Created by Jorge Alvarez on 11/24/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class DaySelectionView: UIStackView {

    /// Array of Dates that hold which days of the week are currently selected
//    var days = [Date]()
    var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
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
        if button.backgroundColor == .white {
            button.backgroundColor = .mixedBlueGreen
            button.tintColor = .white
        } else {
            button.backgroundColor = .white
            button.tintColor = .mixedBlueGreen
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
            day.tag = integer
            day.contentMode = .scaleToFill
//            day.frame = CGRect(x: 0,
//                                y: 0,
//                                width: 20.0,
//                                height: 50.0)
            day.setTitle("\(days[integer])", for: .normal)
            day.backgroundColor = .white
            day.tintColor = .mixedBlueGreen
            day.addTarget(self, action: #selector(selectDay), for: .touchUpInside)
            day.layer.cornerRadius = 7.0
//            day.layer.borderWidth = 2.0
//            day.layer.borderColor = UIColor.mixedBlueGreen.cgColor
        }
    }
}
