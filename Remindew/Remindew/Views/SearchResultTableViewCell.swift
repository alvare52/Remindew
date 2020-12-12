//
//  SearchResultTableViewCell.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/3/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    /// Activity Indicator to show that image is loading
    var spinner: UIActivityIndicatorView!
    
    /// Displays image from plant's image url (or default image if there is none)
    var plantImageView: UIImageView!
    
    /// Displays plant's common name (if any) in bold
    var commonNameLabel: UILabel!
    
    /// Displays plant's scienfific name (if any) in italics
    var scientificNameLabel: UILabel!
    
    /// 8 pt padding
    var standardMargin: CGFloat = CGFloat(8.0)
    
    /// closure that we call when the cell's prepareForReuse method is called
    /// in cellForRow we tell it to try and cancel the load it was performing
    var onReuse: () -> Void = {}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        // remove current image from the cell so it doesn't show old image while loading a new one
        plantImageView.image = nil
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubviews()
    }
    
    /// Sets up all custom views
    private func setUpSubviews() {
    
        // Spinner
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        addSubview(activityIndicator)
        self.spinner = activityIndicator
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(4.0)).isActive = true
        spinner.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        spinner.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CGFloat(-4.0)).isActive = true
        spinner.widthAnchor.constraint(equalTo: spinner.heightAnchor).isActive = true
        spinner.color = .leafGreen
        
        // Image View
        let imageView = UIImageView()
        addSubview(imageView)
        self.plantImageView = imageView
        plantImageView.translatesAutoresizingMaskIntoConstraints = false
        plantImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        plantImageView.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(4.0)).isActive = true
        plantImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CGFloat(-4.0)).isActive = true
        plantImageView.widthAnchor.constraint(equalTo: plantImageView.heightAnchor).isActive = true

        plantImageView.layer.masksToBounds = false
        plantImageView.layer.cornerRadius = 26.0 // half of its size (cellHeight - 8 padding) / 2
        plantImageView.clipsToBounds = true
        plantImageView.contentMode = .scaleToFill
        
        // Title Label
        let label = UILabel()
        addSubview(label)
        self.commonNameLabel = label
        commonNameLabel.translatesAutoresizingMaskIntoConstraints = false
        commonNameLabel.topAnchor.constraint(equalTo: plantImageView.topAnchor, constant: CGFloat(7.0)).isActive = true
        commonNameLabel.leadingAnchor.constraint(equalTo: plantImageView.trailingAnchor,
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
        scientificNameLabel.leadingAnchor.constraint(equalTo: plantImageView.trailingAnchor,
                                             constant: standardMargin).isActive = true
        scientificNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standardMargin).isActive = true
        scientificNameLabel.font = .italicSystemFont(ofSize: 14)
        scientificNameLabel.textColor = .secondaryLabel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
