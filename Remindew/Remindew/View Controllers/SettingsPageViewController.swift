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
        return "\n\nUser Stats: \(totalPlantCount) Plants, \(totalNotificationsCount) Reminders, \(totalLocationsCount) Locations" + "\nv\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.customBackgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            return "APPEARANCE"
        case 1:
            return "SORTING"
        case 2:
            return "SEARCHING"
        case 3:
            return "SEARCHES POWERED BY TREFLE"
        case 4:
            return "DEFAULT IMAGE"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Toggle between Light or Dark Theme"
        case 1:
            return "Sort by nickname or plant type"
        case 2:
            return "Clicking on a search result will replace plant type name with common name of selected result"
        case 3:
            return "The Trefle API aims to increase awareness and understanding of living plants by gathering, generating and sharing knowledge in an open, freely accessible and trusted digital resource."
        case 4:
            return "Images provided by Richard Alfonzo" + stats
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Cast as a custom tableview cell (after I make one)
        guard let settingCell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as? SettingsTableViewCell else { return UITableViewCell() }
        
        // APPEARANCE
        if indexPath.section == 0 {
            settingCell.settingLabel.text = "Dark Theme"
            settingCell.optionSwitch.isHidden = false
            settingCell.customSetting = .darkThemeOn
            settingCell.optionSwitch.isOn = UserDefaults.standard.bool(forKey: .darkThemeOn)
        }
        
        // SORTING
        if indexPath.section == 1 {
            settingCell.settingLabel.text = "Sort by plant type"
            settingCell.optionSwitch.isHidden = false
            settingCell.customSetting = .sortPlantsBySpecies
            settingCell.optionSwitch.isOn = UserDefaults.standard.bool(forKey: .sortPlantsBySpecies)
        }
        
        // SEARCHING
        if indexPath.section == 2 {
            settingCell.settingLabel.text = "Replace type with search result"
            settingCell.optionSwitch.isHidden = false
            settingCell.customSetting = .resultFillsSpeciesTextfield
            settingCell.optionSwitch.isOn = UserDefaults.standard.bool(forKey: .resultFillsSpeciesTextfield)
        }
        
        // SEARCHES POWERED BY TREFLE
        if indexPath.section == 3 {
            settingCell.settingLabel.text = "Trefle API Home Page"
            settingCell.settingLabel.textColor = .link
        }
        
        // IMAGES PROVIDED BY RICHARD ALFONZO
        if indexPath.section == 4 {
            settingCell.settingLabel.text = "Richard Alfonzo Photography"
            settingCell.settingLabel.textColor = .link
        }
        
        return settingCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        let selectedCell = tableView.cellForRow(at: indexPath) as? SettingsTableViewCell
        print("Selected Cell = \(selectedCell?.settingLabel.text ?? "title")")
        
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
