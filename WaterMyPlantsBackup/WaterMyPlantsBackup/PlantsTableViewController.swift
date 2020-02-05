//
//  PlantsTableViewController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit
// PlantCell
// AddPlantSegue
// DetailPlantSegue
// LoginSegue ?
// EditUserSegue
class PlantsTableViewController: UITableViewController {
    
    // MARK: - Properties
    var dummyArray: [String] = ["\"Lucky\" - Daisy", "\"Spot\" - Rose", "\"Grace\" - Lily"]

    @IBOutlet weak var userIcon: UIBarButtonItem!
    @IBOutlet weak var addPlantIcon: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlantIcon.tintColor = .systemGreen
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // show login screen when view did appear
        //performSegue(withIdentifier: "LoginModalSegue", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath)

        // Configure the cell...
        let testCell = dummyArray[indexPath.row]
        cell.textLabel?.text = testCell
        cell.textLabel?.textColor = .systemGreen
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = "Every 3 Days - 6:00PM"
        //cell.detailTextLabel?.textColor = .systemBlue
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // DetailViewController (to ADD plant)
        if segue.identifier == "AddPlantSegue" {
            print("AddPlantSegue")
        }
        
        // DetailViewController (to EDIT plant)
        if segue.identifier == "DetailPlantSegue" {
            print("DetailPlantSegue")
        }
        
        // UserViewController (to EDIT user)
        if segue.identifier == "EditUserSegue" {
            print("EditUserSegue")
        }
    }
}
