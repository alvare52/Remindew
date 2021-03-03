//
//  SettingsPageViewController.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/19/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class SettingsPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // TODO: add setting to disable sections in Sorting settings section?
    // TODO: add setting to display plant type as primary name instead of nickname? Remove sort by species/name setting?
    // TODO: add setting to use plant image instead of icons?
    
    // MARK: - Actions
    
    /// Clear button that sits over progressView (notch) and dismiss view controller when tapped
    @IBAction func clearDismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Properties
    
    /// String that shows how many total plants there are and how many pending notifications there are
    var totalPlantCount = 0
    var totalNotificationsCount = 0
    var totalLocationsCount = 0
    
    /// Returns a String that contains total amount of Plants, Pending Notifications, Locations, and current app version
    var stats: String {
        return "\n\nStats - Plants \(totalPlantCount), Notifications \(totalNotificationsCount), Plant Locations \(totalLocationsCount)" + "\nVersion \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.customBackgroundColor
        
        // Listen for when to check watering status of plants (posted when notification comes in while app is running)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissSettingsPage),
                                               name: .checkWateringStatus,
                                               object: nil)
        
        // Listen for when we update sorting (posted when changing sort settings)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissSettingsPage),
                                               name: .updateSortDescriptors,
                                               object: nil)
    }
    
    /// Dismiss Settings page when appearance setting is toggled to prevent spamming
    @objc func dismissSettingsPage() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update stats
        UNUserNotificationCenter.checkPendingNotes { result in
            DispatchQueue.main.async {
                self.totalNotificationsCount = result
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        
        case 0:
            return NSLocalizedString("APPEARANCE", comment: "appearance section title")
        case 1:
            return NSLocalizedString("MAIN LABEL", comment: "main label section title")
        case 2:
            return "SEARCHING"
        case 3:
            return "SEARCHES POWERED BY TREFLE"
        case 4:
            return NSLocalizedString("DEFAULT PLANT IMAGE", comment: "default plant image section title")
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Light/Dark theme are independent of phone settings. Main screen displays plant icon instead of image by default."
        case 1:
            return "Top label displays nickname by default. Label color is dark green instead of selected color by default."
        case 2:
            return "Clicking on a search result will replace plant type name with common name of selected result. Search by tapping \"search\" on keyboard when entering plant's type"
        case 3:
            return "Trefle aims to increase awareness and understanding of living plants by gathering, generating and sharing knowledge in an open, freely accessible and trusted digital resource."
        case 4:
            return "Default plant photo provided by Richard Alfonzo." + stats
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Appearance
        if section == 0 {
            return 3
        }
        
        // Main Label
        if section == 1 {
            return 2
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Cast as a custom tableview cell (after I make one)
        guard let settingCell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as? SettingsTableViewCell else { return UITableViewCell() }
        
        // APPEARANCE
        if indexPath.section == 0 {
            
            // Dark Theme
            if indexPath.row == 0 {
                settingCell.settingLabel.text = "Dark Theme"
                settingCell.optionSwitch.isHidden = false
                settingCell.customSetting = .darkThemeOn
                settingCell.optionSwitch.isOn = UserDefaults.standard.bool(forKey: .darkThemeOn)
                settingCell.settingLabel.textColor = .label
            }
            
            // Plant Images
            if indexPath.row == 1 {
                settingCell.settingLabel.text = "Images Instead of Icons"
                settingCell.optionSwitch.isHidden = false
                settingCell.customSetting = .usePlantImages
                settingCell.optionSwitch.isOn = UserDefaults.standard.bool(forKey: .usePlantImages)
                settingCell.settingLabel.textColor = .label
            }
            
            // Plant Images
            if indexPath.row == 2 {
                settingCell.settingLabel.text = "Hide Silenced Icon"
                settingCell.optionSwitch.isHidden = false
                settingCell.customSetting = .hideSilencedIcon
                settingCell.optionSwitch.isOn = UserDefaults.standard.bool(forKey: .hideSilencedIcon)
                settingCell.settingLabel.textColor = .label
            }
        }
        
        // Main Label
        if indexPath.section == 1 {
            
            // Nickname / Species Label
            if indexPath.row == 0 {
                settingCell.settingLabel.text = "Use Plant Type Instead"
                settingCell.optionSwitch.isHidden = false
                settingCell.customSetting = .sortPlantsBySpecies
                settingCell.optionSwitch.isOn = UserDefaults.standard.bool(forKey: .sortPlantsBySpecies)
                settingCell.settingLabel.textColor = .label
            }
            
            // Label uses plant color
            if indexPath.row == 1 {
                settingCell.settingLabel.text = "Label Uses Plant Color"
                settingCell.optionSwitch.isHidden = false
                settingCell.customSetting = .usePlantColorOnLabel
                settingCell.optionSwitch.isOn = UserDefaults.standard.bool(forKey: .usePlantColorOnLabel)
                settingCell.settingLabel.textColor = .label
            }
        }
        
        // SEARCHING
        if indexPath.section == 2 {
            settingCell.settingLabel.text = "Replace Type with Search Result"
            settingCell.optionSwitch.isHidden = false
            settingCell.customSetting = .resultFillsSpeciesTextfield
            settingCell.optionSwitch.isOn = UserDefaults.standard.bool(forKey: .resultFillsSpeciesTextfield)
            settingCell.settingLabel.textColor = .label
        }
        
        // SEARCHES POWERED BY TREFLE
        if indexPath.section == 3 {
            settingCell.settingLabel.text = "Trefle API Home Page"
            settingCell.settingLabel.textColor = .link
            settingCell.optionSwitch.isHidden = true
        }
        
        // IMAGES PROVIDED BY RICHARD ALFONZO
        if indexPath.section == 4 {
            settingCell.settingLabel.text = NSLocalizedString("Richard Alfonzo Photography", comment: "default image source link")
            settingCell.settingLabel.textColor = .link
            settingCell.optionSwitch.isHidden = true
        }
        
        return settingCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        let selectedCell = tableView.cellForRow(at: indexPath) as? SettingsTableViewCell
        print("Selected Cell = \(selectedCell?.settingLabel.text ?? "title")")
        
        // Prevents visual bug when selecting setting body instead of switch button
        tableView.deselectRow(at: indexPath, animated: true)
        
        // if Trefle API cell is selected, go to Trefle API home page
        if indexPath.section == 3 {
            guard let url = URL(string: "https://trefle.io/") else { return }
            UIApplication.shared.open(url)
        }
        
        // if Richard Alfonzo Photography cell is selected, go to Richard Alfonzo Photography home page
        if indexPath.section == 4 {
            guard let url = URL(string: "https://rnalfonzo.smugmug.com") else { return }
            UIApplication.shared.open(url)
        }
    }
}
