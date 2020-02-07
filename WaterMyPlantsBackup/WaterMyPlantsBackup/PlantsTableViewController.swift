//
//  PlantsTableViewController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class PlantsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    
    lazy var fetchedResultsController: NSFetchedResultsController<Plant> = {
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "nickname", ascending: true)]

        let context = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: "nickname",
                                             cacheName: nil)
        frc.delegate = self
        try! frc.performFetch() // do it and crash if you have to
        return frc
    }()
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        //formatter.dateStyle = .short
        formatter.dateFormat = "EEEE MMM d, h:mm a"
        //formatter.timeStyle = .short
        return formatter
    }
    
    var timer: Timer?
    let userController = UserController()

    @IBOutlet weak var userIcon: UIBarButtonItem!
    @IBOutlet weak var addPlantIcon: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addPlantIcon.tintColor = .systemGreen
        startTimer()
        // CHANGE BACK TO VIEWDIDAPPEAR LATER
        performSegue(withIdentifier: "LoginModalSegue", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // show login screen when view did appear
        // THIS IS WHERE PERFORMSEGUE SHOULD BE LATER
        //performSegue(withIdentifier: "LoginModalSegue", sender: self)
        //tableView.reloadData()
    }
    
    /// Main timer that is used to check all plants being tracked
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: updateTimer(timer:))
        RunLoop.current.add(timer!, forMode: .common)
        timer?.tolerance = 0.1
    }
    
    /// Will only run when app is not in the foreground
    func sendNotification() {
        let note = UNMutableNotificationContent()
        note.title = "WATER YOUR PLANT!"
        note.body = "DO IT! DO IT NOW!"
        note.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier: "done", content: note, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    /// Updates all plants and displays alert
    func updateTimer(timer: Timer) {
        
        for plant in fetchedResultsController.fetchedObjects! {
            // convert?
            guard let schedule = plant.water_schedule else {return}
            if schedule <= Date() {
                print("WATER YOUR PLANT")
                sendNotification()
                plant.water_schedule = Date(timeIntervalSinceNow: TimeInterval(86400 * Double(plant.frequency)))
                localAlert(plant: plant)
                //testPlants.remove(at: testPlants.firstIndex(of: fakePlant)!)
                tableView.reloadData()
            }
        }
    }
    
    func localAlert(plant: Plant) {
        guard let schedule = plant.water_schedule, let nickname = plant.nickname else {return}
        
        let nextDate: String = dateFormatter.string(from: schedule)
        let alert = UIAlertController(title: "Water your plant!", message: "Start watering \(nickname)! \n Next watering date: \(nextDate)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath)
    
        // TEST
        //let testCell = testPlants[indexPath.row]
        let testCell = fetchedResultsController.object(at: indexPath)
        
        guard let nickname = testCell.nickname, let species = testCell.species else {return cell}
        
        cell.textLabel?.text = "\"\(nickname)\" - \(species)"
        //cell.textLabel?.textColor = .systemGreen
        //cell.textLabel?.textColor = UIColor(red: 62, green: 79, blue: 36, alpha: 1)
        cell.accessoryType = .disclosureIndicator
        let shit = Date(timeIntervalSinceNow: 69)
        if testCell.frequency == 1 {
            cell.detailTextLabel?.text = "Every day - \(dateFormatter.string(from: testCell.water_schedule ?? shit ))"
        } else {
            cell.detailTextLabel?.text = "Every \(testCell.frequency) days - \(dateFormatter.string(from: testCell.water_schedule ?? shit))" }
        // TEST
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let plant = fetchedResultsController.object(at: indexPath)
            // delete from server first before we do local delete
            userController.deletePlantFromServer(plant: plant) { error in
                if let error = error {
                    print("Error deleting plant from server: \(error)")
                    return
                }
                
                CoreDataStack.shared.mainContext.delete(plant)
                do {
                    try CoreDataStack.shared.mainContext.save()
                } catch {
                    CoreDataStack.shared.mainContext.reset() // UN-deletes
                    NSLog("Error saving managed object context: \(error)")
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LoginModalSegue" {
            guard let destination = segue.destination as? LoginViewController else {return}
            destination.userController = self.userController
        }
        
        // DetailViewController (to ADD plant)
        if segue.identifier == "AddPlantSegue" {
            print("AddPlantSegue")
            if let detailVC = segue.destination as? DetailViewController {
                    detailVC.userController = self.userController
                }
            }
        // DetailViewController (to EDIT plant)
        if segue.identifier == "DetailPlantSegue" {
            print("DetailPlantSegue")
            if let detailVC = segue.destination as? DetailViewController, let indexPath = tableView.indexPathForSelectedRow {
                detailVC.userController = self.userController
                detailVC.plant = fetchedResultsController.object(at: indexPath)
            }
        }
        // UserViewController (to EDIT user)
        if segue.identifier == "EditUserSegue" {
            print("EditUserSegue")
        }
    }
}


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


