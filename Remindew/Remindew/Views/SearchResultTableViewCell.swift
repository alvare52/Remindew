//
//  SearchResultTableViewCell.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/3/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    /// Displays image from plant's image url (or default image if there is none)
    var plantImageView: UIImageView!
    
    /// Displays plant's common name (if any) in bold
    var commonNameLabel: UILabel!
    
    /// Displays plant's scienfific name (if any) in italics
    var scientificNameLabel: UILabel!
    
    /// 8 pt padding
    var standardMargin: CGFloat = CGFloat(8.0)
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubviews()
    }
    
    /// Sets up all custom views
    private func setUpSubviews() {
    
        // Image View
        let imageView = UIImageView()
        addSubview(imageView)
        self.plantImageView = imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(4.0)).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CGFloat(-4.0)).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true

        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 21.0 // half of its size
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1.0
        
        // Title Label
        let label = UILabel()
        addSubview(label)
        self.commonNameLabel = label
        commonNameLabel.translatesAutoresizingMaskIntoConstraints = false
        commonNameLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: CGFloat(4.0)).isActive = true
        commonNameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor,
                                            constant: standardMargin).isActive = true
        commonNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standardMargin).isActive = true
        commonNameLabel.textColor = .label
        commonNameLabel.font = .boldSystemFont(ofSize: 16)
        
        // Author Label
        let author = UILabel()
        addSubview(author)
        self.scientificNameLabel = author
        scientificNameLabel.translatesAutoresizingMaskIntoConstraints = false
        scientificNameLabel.topAnchor.constraint(equalTo: commonNameLabel.bottomAnchor).isActive = true
        scientificNameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor,
                                             constant: standardMargin).isActive = true
        scientificNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standardMargin).isActive = true
        scientificNameLabel.font = .italicSystemFont(ofSize: 14)
        scientificNameLabel.textColor = .secondaryLabel
    }
    
    override func awakeFromNib() {
        print("awakeFromNib")
        super.awakeFromNib()
        setUpSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
