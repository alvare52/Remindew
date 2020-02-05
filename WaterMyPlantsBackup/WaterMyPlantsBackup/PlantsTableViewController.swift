//
//  PlantsTableViewController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit
import CoreData
// PlantCell
// AddPlantSegue
// DetailPlantSegue
// LoginSegue ?
// EditUserSegue

// TEST
var testPlants: [FakePlant] = [FakePlant(nickname: "Jackie",
      species: "Tulip",
      water_schedule: Date(timeIntervalSinceNow: 3),
      last_watered: nil,
      frequency: 3,
      image_url: nil,
      id: 1),
FakePlant(nickname: "Tanya",
      species: "Dandelion",
      water_schedule: Date(timeIntervalSinceNow: 9),
      last_watered: nil,
      frequency: 2,
      image_url: nil,
      id: 2),
FakePlant(nickname: "Paula",
      species: "Rose",
      water_schedule: Date(timeIntervalSinceNow: 15),
      last_watered: nil,
      frequency: 1,
      image_url: nil,
      id: 3)]
// TEST

class PlantsTableViewController: UITableViewController {
    
    // MARK: - Properties
    // Add later
    //private let plantController = PlantController()
        
    // use User instead???
//    lazy var fetchedResultsController: NSFetchedResultsController<Plant> = {
//        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true),
//                                        NSSortDescriptor(key: "name", ascending: true)]
//
//        let context = CoreDataStack.shared.mainContext
//        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
//                                             managedObjectContext: context,
//                                             sectionNameKeyPath: "priority",
//                                             cacheName: nil)
//        frc.delegate = self
//        try! frc.performFetch() // do it and crash if you have to
//        return frc
//    }()
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    var timer: Timer?

    @IBOutlet weak var userIcon: UIBarButtonItem!
    @IBOutlet weak var addPlantIcon: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlantIcon.tintColor = .systemGreen
        startTimer()
        
        performSegue(withIdentifier: "LoginModalSegue", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // show login screen when view did appear
        //performSegue(withIdentifier: "LoginModalSegue", sender: self)
        tableView.reloadData()
    }
    
    /// Main timer that is used to check all events being tracked
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: updateTimer(timer:))
        RunLoop.current.add(timer!, forMode: .common)
        timer?.tolerance = 0.1
    }
    
    /// Updates all events, removes them when finished and displays alert (or notification)
    func updateTimer(timer: Timer) {
        
        for fakePlant in testPlants {
            if fakePlant.water_schedule <= Date() {
                print("WATER YOUR PLANT")
                localAlert(fakePlant: fakePlant)
                fakePlant.water_schedule = Date(timeIntervalSinceNow: TimeInterval(86400 * fakePlant.frequency))
                //testPlants.remove(at: testPlants.firstIndex(of: fakePlant)!)
                tableView.reloadData()
            }
        }
    }
    
    func localAlert(fakePlant: FakePlant) {
        let alert = UIAlertController(title: "Water your plant!", message: "Start watering \(fakePlant.nickname)!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testPlants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath)

        // Configure the cell...
    
        // TEST
        let testCell = testPlants[indexPath.row]
        cell.textLabel?.text = "\(testCell.nickname) - \(testCell.species)"
        cell.textLabel?.textColor = .systemGreen
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = "Every \(testCell.frequency) days - \(dateFormatter.string(from: testCell.water_schedule))"
        // TEST
        
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
            //guard let detailVC = segue.destination as? DetailViewController else {return}
            
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

// TEST
class FakePlant: Equatable {
    
    static func == (lhs: FakePlant, rhs: FakePlant) -> Bool {
        return lhs.nickname == rhs.nickname && lhs.species == rhs.species
    }
    
    var nickname: String
    var species: String
    var water_schedule: Date
    var last_watered: Date?
    var frequency: Int
    var image_url: String?
    var id: Int
    
    init(nickname: String, species: String, water_schedule: Date, last_watered: Date?, frequency: Int = 0, image_url: String?, id: Int) {
        self.nickname = nickname
        self.species = species
        self.water_schedule = water_schedule
        self.last_watered = last_watered
        self.frequency = frequency
        self.image_url = image_url
        self.id = id
    }
}
// TEST


extension PlantsTableViewController: NSFetchedResultsControllerDelegate {
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}


