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
    
    var standardMargin: CGFloat = CGFloat(8.0)
    
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
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                            constant: CGFloat(0.0)).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(4.0)).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CGFloat(-4.0)).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true

        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 20.0 // half of its size
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
        scientificNameLabel.topAnchor.constraint(equalTo: commonNameLabel.bottomAnchor,
                                         constant: standardMargin * 0).isActive = true
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
    
    /// ?
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
