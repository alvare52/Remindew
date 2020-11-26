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

class PlantsTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var addPlantIcon: UIBarButtonItem!
    
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
        //formatter.dateStyle = .short
        formatter.dateFormat = "EEEE MMM d, h:mm a"
        //formatter.timeStyle = .short
        return formatter
    }
    
    var timer: Timer?
    let userController = PlantController()
    let calendar = Calendar.current
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            guard let schedule = plant.water_schedule else { return }
            
            // NEW
            let selectedDate = schedule
//            print("selected date is \(selectedDate)")
            
            let otherDate = calendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday],
                                                    from: selectedDate)
//            print("selected hour = \(otherDate.hour), minutes = \(otherDate.minute), d = \(otherDate.weekday)")
            
            let currentDateComps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday],
                                                           from: Date())
//            print("curr hour = \(currentDateComps.hour), minutes = \(currentDateComps.minute), d = \(currentDateComps.weekday)")
            
            guard let scheduleHour = otherDate.hour,
                let currHour = currentDateComps.hour,
                let scheduleMinute = otherDate.minute,
                let currMinute = currentDateComps.minute,
                let scheduleDay = otherDate.weekday,
                let currDay = currentDateComps.weekday else { return }
            
            if schedule <= Date() {
                print("TIME MATCHES, \(plant.nickname)")
                // update schedule so it doesn't keep going off
                                
                print(plant.water_schedule)
//                let val = userController.calculateNextWateringValue(plant.frequency!)

                plant.water_schedule = userController.returnWateringSchedule(plantDate: plant.water_schedule ?? Date(),
                                                                             days: plant.frequency!)
                print(plant.water_schedule)
                
                // NEW
                print("Plant: \(plant.nickname ?? "plant") Schedule: \(dateFormatter.string(from: schedule))")
                print("WATER YOUR PLANT: \(plant.nickname ?? "!")")
                sendNotification(plant: plant.nickname ?? "YOUR PLANT")
                
                // update the plants schedule after it goes off, and then add frequency days to make its new schedule
//                plant.water_schedule = Date(timeIntervalSinceNow: TimeInterval(86400 * Double(plant.frequency)))
                
                // then update plant to have its new schedule
                let newDate = userController.returnWateringSchedule(plantDate: plant.water_schedule ?? Date(),
                                                                    days: plant.frequency!)
                
                // UDPATE SCHEDULE - CHANGE BACK MAYBE
                guard let nickname = plant.nickname, let species = plant.species, let water_schedule = plant.water_schedule else {return}
                userController.update(nickname: nickname,
                                      species: species,
                                      water_schedule: water_schedule,
                                      frequency: plant.frequency!,
                                      plant: plant)
                // UPDATE SCHEDULE - CHANGE BACK MAYBE
                
                localAlert(plant: plant)
                tableView.reloadData()
                // NEW
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
        
        
        cell.detailTextLabel?.text = "MWF - \(dateFormatter.string(from: testCell.water_schedule ?? temp))"
        
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


