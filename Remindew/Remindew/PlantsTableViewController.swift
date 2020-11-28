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
import AVFoundation

// TODO: add needsWatering, image, webImage, lastWateredDate, 
// TODO: delete all unneeded comments
// TODO: screen size issues
// TODO: improve README (Gif, About, tech ribbons)
// TODO: notifications fixes (not allowed, access description)
// TODO: add Unit/UI tests
// TODO: add better comments/Marks
// TODO: UI polish, sounds, font, transparency
// TODO: add Protocols?
// TODO: remote notification even when app closed
// TODO: app store preview screen shots (blue, blue green, green)
// TODO: add ability to add photo for plant
// TODO: add settings button/page (auto water plants, shout out to Trefle API)
// TODO: AFTER: let user take picture from app? toggle every x days vs days of week
// TODO: add parameter descriptions
// TODO: tableview drawing warning
// TODO: ValueTransformer warning Core Data
// TODO: changing day to next week at earlier time still triggers notification
// TODO: add better error handling to detail screen
// TODO: make nickname not mandatory to make plant ("" default value?)
// TODO: enable dateLabel BB items to toggle between format?
// TODO: BUG: when alarm goes off when app is closed, its new time is set to the current plus next day
// TODO: launch animation where drop slides in front of leaf

class PlantsTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var addPlantIcon: UIBarButtonItem!
    
    @IBOutlet var dateLabel: UIBarButtonItem!
    // MARK: - Properties
    
    /// Fetches Plant objects from storage
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
        formatter.dateFormat = "EEEE MMM d, h:mm a"
        return formatter
    }
    
    var dateFormatter2: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE MM/d"
            return formatter
    }
    
    var timer: Timer?
    let userController = PlantController()
    let calendar = Calendar.current
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
//                switch granted {
//                case true:
//
//                    var date = DateComponents()
//                    date.hour = 12 + 4
//                    date.minute = 11
//                    date.weekday = 6
//                    let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
//                    let content = UNMutableNotificationContent()
//                    content.sound = .default
//                    content.title = "PLANT NEEDS WATER!"
//                    content.body = "PLANT NEEDS WATER!"
//
//                    let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
//                    UNUserNotificationCenter.current().add(request) { (error) in
//                        if let error = error {
//                            NSLog("Error adding notification: \(error)")
//                        }
//                        print("Added notification")
//                        UNUserNotificationCenter.current().getPendingNotificationRequests { (note) in
//                            print("pending note requests = \(note)")
//                            for thing in note {
//                                print(thing.identifier)
//                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["testNotification"])
//                            }
//                        }
//                        UNUserNotificationCenter.current().getPendingNotificationRequests { (note) in
//                            print("pending note requests NOW = \(note)")
//
//                        }
//
//                    }
//                case false:
//                    print("access NOT granted!")
//                    break
//                }
//            }
        
        dateLabel.title = dateFormatter2.string(from: Date())
        dateLabel.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mixedBlueGreen], for: .disabled)
        startTimer()
    }
    
    /// Main timer that is used to check all plants being tracked
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: updateTimer(timer:))
        RunLoop.current.add(timer!, forMode: .common)
        timer?.tolerance = 0.1
    }
    
    /// Will only run when app is not in the foreground
    func sendNotification(plant: String) {
        let note = UNMutableNotificationContent()
        note.title = "Water your plant!"
        note.body = "\(plant) needs to be watered!"
        note.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier: "done", content: note, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    /// Schedules the next notification so it goes off when app is in background
    func setupNextNotification() {
       print("setup next notification")
    }
    
    /// Updates all plants and displays alert
    func updateTimer(timer: Timer) {
        for plant in fetchedResultsController.fetchedObjects! {
            // convert?
            
//            print("\(plant.frequency![0]) + \(plant.identifier!)")
//            print("\(plant.frequency![0])\(plant.identifier!)")
            
            guard let schedule = plant.water_schedule else { return }
                        
            if schedule <= Date() {
                print("water_schedule = \(dateFormatter.string(from: schedule))")
                print("TIME MATCHES, \(plant.nickname ?? "Plant Name error")")
                                
//                plant.water_schedule = userController.returnWateringSchedule(plantDate: plant.water_schedule ?? Date(),
//                                                                             days: plant.frequency!)
                // then update plant to have its new schedule
                let newDate = userController.returnWateringSchedule(plantDate: plant.water_schedule ?? Date(),
                                                                    days: plant.frequency!)
                
                print("newDate = \(dateFormatter.string(from: newDate))")
                userController.updatePlantWithSchedule(plant: plant, schedule: newDate)
                
                sendNotification(plant: plant.nickname ?? "Your plants")
                localAlert(plant: plant)
                tableView.reloadData()
            }
        }
    }
    
    /// Presents Alert View when reminder goes off while app is running
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
    
        let testCell = fetchedResultsController.object(at: indexPath)
        
        guard let nickname = testCell.nickname, let species = testCell.species else {return cell}
        
        cell.textLabel?.text = "\"\(nickname)\" - \(species)"
        //cell.textLabel?.textColor = .systemGreen
        //cell.textLabel?.textColor = UIColor(red: 62, green: 79, blue: 36, alpha: 1)
        cell.accessoryType = .disclosureIndicator
        let temp = Date(timeIntervalSinceNow: 69)
        
        let daysString = userController.returnDaysString(plant: testCell)
        cell.detailTextLabel?.text = "\(daysString) - \(dateFormatter.string(from: testCell.water_schedule ?? temp))"
        
        cell.imageView?.image = UIImage(named: "planticonwater")
        return cell
    }
    
    /// Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let plant = fetchedResultsController.object(at: indexPath)
            userController.deletePlant(plant: plant)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
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
    }
}

/// Core Data boiler plate code
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


