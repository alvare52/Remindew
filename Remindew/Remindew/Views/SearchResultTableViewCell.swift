//
//  SearchResultTableViewCell.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/3/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    var plantResult: PlantSearchResult? {
        didSet {
            updateViews()
        }
    }

    var plantImageView: UIImageView!
    
    var commonNameLabel: UILabel!
    
    var scientificNameLabel: UILabel!
    
    var standardMargin: CGFloat = CGFloat(16.0)
    
    private func updateViews() {
        
        guard let plantResult = plantResult else { return }
        
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubviews()
    }
    
    private func setUpSubviews() {
        print("setUpSubviews")
        
        textLabel!.translatesAutoresizingMaskIntoConstraints = false
        textLabel!.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat(40.0)).isActive = true
        
        // Image View
        let imageView = UIImageView()
        addSubview(imageView)
        self.plantImageView = imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                            constant: CGFloat(-12.0)).isActive = true
//        imageView.widthAnchor.constraint(equalTo: widthAnchor,
//                                         multiplier: 0.6).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(4.0)).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CGFloat(-4.0)).isActive = true
//        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
//        imageView.heightAnchor.constraint(equalTo: heightAnchor,
//                                          multiplier: 0.3).isActive = true
        //imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 3 / 4).isActive = true
        // mult for height used to be 1.5 of imageView.widthAnchor // widthAnchor used to be 0.25
        
        imageView.contentMode = .scaleToFill // used to be .scaleAspectFit
        imageView.clipsToBounds = true
        
//        imageView.layer.cornerRadius = 5

        // makes imageView a circle
//        imageView.layer.borderWidth = 1.0
        imageView.layer.masksToBounds = false
//        imageView.layer.borderColor = UIColor.white.cgColor
        print("imageView frame width = \(imageView.frame.size.width)")
        imageView.layer.cornerRadius = 40.0 / 2
        imageView.clipsToBounds = true
//        imageView.backgroundColor = .white
        imageView.contentMode = .scaleToFill
        
    }
    
    override func awakeFromNib() {
        print("awakeFromNib")
        super.awakeFromNib()
        setUpSubviews()
    }
    
    /// ?
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
