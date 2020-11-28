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
// TODO: add badges
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
// TODO: auto select first textfield when adding new plant
// TODO: small bug. checkWatering will run in most cases except when you stay on the table view
// TODO: small bug. updating time for plant that was already watered that day won't work right
// TODO: fix water plant button in detail view controller

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
        formatter.timeStyle = .short
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
    private var observer: NSObjectProtocol?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.title = dateFormatter2.string(from: Date())
        dateLabel.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mixedBlueGreen], for: .disabled)
//        startTimer()
                
        // Add observer so we can know when the app comes back in the foreground
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            // [unowned self] is so avoid strong reference cycle that prevents VC from being deallocated
            // do this when app is brought back to the foreground
            print("BACK IN THE FOREGROUND")
            self.checkIfPlantsNeedWatering()
        }

    }
    
    /// Remove observer when deallocating this view controller
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    /// Check which plants need water when app comes back from detail screen or first starts up. Chose
    /// this over viewDidAppear so title would update before it's visible. Change back if there's issues
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        checkIfPlantsNeedWatering()
    }
    
    /// Goes through all plants and checks if they need watering today. Also updates title based on how many need water
    private func checkIfPlantsNeedWatering() {
        print("checkIfPlantNeedsWatering")
        
        // for tallying up all plants that need watering
        var count = 0
        
        // each plant if it's next water date has passed
        for plant in fetchedResultsController.fetchedObjects! {
            
            // get current weekday from calendar first
            let currentDayComps = calendar.dateComponents([.day, .hour, .minute, .second, .weekday], from: Date())
            let currentWeekday = Int16(currentDayComps.weekday!)
            let currentHour = currentDayComps.hour!
            let currentMinute = currentDayComps.minute!
            let currentDay = currentDayComps.day!
            
            // if today is one of the selected days for this plant
            if let _ = plant.frequency!.firstIndex(of: currentWeekday) {
//                print("today = \(currentWeekday) \(currentHour):\(currentMinute), it IS index \(day) in plant frequency")
                // now check if plant.water_schedule time is <= currentMinute and
                let plantComps = calendar.dateComponents([.hour, .minute, .second], from: plant.water_schedule!)
                let plantHour = plantComps.hour!
                let plantMinute = plantComps.minute!
                
//                print("plant time = \(plantHour):\(plantMinute):\(plantSecond)")
//                print("current time = \(currentHour):\(currentMinute):\(currentSecond)")
//                print("plant needs waterin = \(plant.needsWatering)")
                
                var lastDay = 0
                if let lastWatered = plant.lastDateWatered {
//                    print("lastWatered was NOT nil, so its a plant that has been watered before")
                    lastDay = calendar.dateComponents([.day, .hour, .minute, .second, .weekday], from: lastWatered).day!
                } else {
//                    print("lastWatered was nil, so its a fresh plant")
                    lastDay = 100
                }
                
//                print("lastDay: \(lastDay), current day: \(currentDay)")
                
                // as it's still the same day. check if last date watered day and hour against today
                if plantHour <= currentHour && plantMinute <= currentMinute && !plant.needsWatering && lastDay != currentDay {
                    // first time this goes off, set plant needsWatering to true
                    // then check if needsWatering is false so this only triggers once
                    
                    // needsWatering goes from FALSE to TRUE (don't update last watered)
                    userController.updatePlantWithWatering(plant: plant, needsWatering: true)
                
                    // play sound effect instead?
                    //localAlert(plant: plant)
                
                    tableView.reloadData()
                }
                
            } else {
//                print("Today is NOT in plant's days array")
            }
            
            // count all plants that need watering for title display
            if plant.needsWatering { count += 1 }
        }
        
        // update title after all plant watering statuses have been checked
        title = count > 0 ? "Remindew - (\(count))" : "Remindew"
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
        
        if testCell.needsWatering {
            cell.imageView?.image = UIImage(named: "planticonwater")
        } else {
            cell.imageView?.image = UIImage(named: "planticonleaf")
        }
        
        return cell
    }
    
    /// Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let plant = fetchedResultsController.object(at: indexPath)
            userController.removeAllRequestsForPlant(plant: plant)
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


