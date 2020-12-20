//
//  SettingsPageViewController.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/19/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class SettingsPageViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.customBackgroundColor
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingsPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "SORTING"
        case 1:
            return "SEARCHING"
        case 2:
            return "SEARCHES POWERED BY TREFLE"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Total plants: 5"
        case 2:
            return "The Trefle API aims to increase awareness and understanding of living plants by gathering, generating and sharing knowledge in an open, freely accessible and trusted digital resource. By using Trefle you accept and agree to abide by the its terms and conditions."
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if indexPath.section == 2 {
//            print("try to make a regular cell")
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
//            cell.textLabel?.text = "Go to Trefle API Home Page"
//            cell.accessoryType = .disclosureIndicator
//            return cell
//        }
        
        // Cast as a custom tableview cell (after I make one)
        guard let settingCell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as? SettingsTableViewCell else { return UITableViewCell() }
        
        settingCell.settingLabel.text = "Setting"
        if indexPath.section == 2 {

            settingCell.settingLabel.text = "Trefle API Home Page"
            settingCell.optionSwitch.isHidden = true
            settingCell.optionSwitch.isEnabled = false
        }

        return settingCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        let selectedCell = tableView.cellForRow(at: indexPath) as? SettingsTableViewCell
        print("Selected Cell = \(selectedCell?.settingLabel.text ?? "title")")
        if indexPath.section == 2 {
            guard let url = URL(string: "https://trefle.io/") else { return }
            UIApplication.shared.open(url)
        }
    }
}
