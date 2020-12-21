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

class PlantsTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var settingsBarButtonLabel: UIBarButtonItem!
    
    @IBOutlet weak var addPlantIcon: UIBarButtonItem!
    
    @IBOutlet var dateLabel: UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func settingsBarButtonTapped(_ sender: UIBarButtonItem) {
        // Bring up settings tab??? disconnect this maybe?
        print("settingsBarButtonTapped")
        plantController.printLastTokenAndDate()
        performSegue(withIdentifier: "ShowSettingsSegue", sender: self)
    }
    
    @IBAction func addPlantButtonTapped(_ sender: UIBarButtonItem) {
        print("addPlantButtonTapped")
//        AudioServicesPlaySystemSound(SystemSoundID(1057))// 1057
        performSegue(withIdentifier: "AddPlantSegue", sender: self)
    }
    // MARK: - Properties
    
    /// Fetches Plant objects from storage
    lazy var fetchedResultsController: NSFetchedResultsController<Plant> = {
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        
        print("FetchedResultsController fetching now")
        // default is to sort by nickname
        var sortKey = "nickname"
        
        // if we DO sort by species instead of nickname, do the following
        if UserDefaults.standard.bool(forKey: .sortPlantsBySpecies) {
            print("Sorting by species instead")
            sortKey = "species"
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: true)]

        let context = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: sortKey,
                                             cacheName: nil)
        frc.delegate = self
        try! frc.performFetch() // do it and crash if you have to
        return frc
    }()
    
    /// Date formatter for table view cell
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    /// Date formatter for nav bar button
    var dateFormatter2: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE MM/d"
            return formatter
    }
    
    var timer: Timer?
    let plantController = PlantController()
    let calendar = Calendar.current
    private var observer: NSObjectProtocol?
    
    var plantsThatNeedWaterCount = 0 {
        didSet {
            // update title after all plant watering statuses have been checked
            title = plantsThatNeedWaterCount > 0 ? "Remindew - (\(plantsThatNeedWaterCount))" : "Remindew"
            // update badge here?
            UIApplication.shared.applicationIconBadgeNumber = plantsThatNeedWaterCount
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Step 2 (step 3 is the thing in selector)
        NotificationCenter.default.addObserver(self,
        selector: #selector(checkIfPlantsNeedWatering),
        name: .checkWateringStatus,
        object: nil)
        
        // capitalized so it does it in Spanish too
        dateLabel.title = dateFormatter2.string(from: Date()).capitalized
        dateLabel.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mixedBlueGreen], for: .disabled)
                
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
        // just in case notifications are turned off
        checkIfPlantsNeedWatering()
    }
    
    /// Goes through all plants and checks if they need watering today. Also updates title based on how many need water
    @objc private func checkIfPlantsNeedWatering() {
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
                print("today = \(currentWeekday) \(currentHour):\(currentMinute)")
                // now check if plant.water_schedule time is <= currentMinute and
                let plantComps = calendar.dateComponents([.hour, .minute, .second], from: plant.water_schedule!)
                let plantHour = plantComps.hour!
                let plantMinute = plantComps.minute!
                
                print("plant time = \(plantHour):\(plantMinute)")
                print("current time = \(currentHour):\(currentMinute)")
                print("plant needs watering = \(plant.needsWatering)")
                
                var lastDay = 0
                if let lastWatered = plant.lastDateWatered {
                    // lastWatered was NOT nil, so its a plant that has been watered before
                    // lastDay is now the weekday int of last day that plant was watered
                    lastDay = calendar.dateComponents([.day, .hour, .minute, .second, .weekday], from: lastWatered).day!
                } else {
                    // lastWatered is nil (Brand new plant)
                    lastDay = 100
                }
                                
                // as it's still the same day. check if last date watered day and hour against today
                if plantHour <= currentHour && plantMinute <= currentMinute && !plant.needsWatering && lastDay != currentDay {
                    // first time this goes off, set plant needsWatering to true
                    // then check if needsWatering is false so this only triggers once
                    
                    // needsWatering goes from FALSE to TRUE (don't update last watered)
                    plantController.updatePlantWithWatering(plant: plant, needsWatering: true)
                    tableView.reloadData()
                }
                
            } else {
                print("Today is NOT in plant's days array")
            }
            
            // count all plants that need watering for title display
            if plant.needsWatering { count += 1 }
        }
        
        // update counter
        plantsThatNeedWaterCount = count
        
        // update date label since it needs to be updated at least once a day to display correct date
        dateLabel.title = dateFormatter2.string(from: Date()).capitalized
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath) as? PlantsTableViewCell else {
            return UITableViewCell()
        }
    
        let testCell = fetchedResultsController.object(at: indexPath)
        
        guard let nickname = testCell.nickname, let species = testCell.species else {return cell}
        
        let temp = Date(timeIntervalSinceNow: 60)

        let daysString = plantController.returnDaysString(plant: testCell)
        
        cell.nicknameLabel.text = nickname
        cell.timeLabel.text = "\(dateFormatter.string(from: testCell.water_schedule ?? temp))"
        cell.speciesLabel.text = species
        cell.daysLabel.text = "\(daysString)"
        
        if testCell.needsWatering {
            cell.plantImageView?.image = UIImage(named: "planticonwater")
        } else {
            cell.plantImageView?.image = UIImage(named: "planticonleaf")
        }
        return cell
    }
    
    /// Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let plant = fetchedResultsController.object(at: indexPath)
            UIImage.deleteImage("userPlant\(plant.identifier!)")
            plantController.removeAllRequestsForPlant(plant: plant)
            plantController.deletePlant(plant: plant)
            checkIfPlantsNeedWatering() // to update badge/count
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        // DetailViewController (to ADD plant)
        if segue.identifier == "AddPlantSegue" {
            print("AddPlantSegue")
            if let detailVC = segue.destination as? DetailViewController {
                    detailVC.plantController = self.plantController
                }
            }
        
        // DetailViewController (to EDIT plant)
        if segue.identifier == "DetailPlantSegue" {
            print("DetailPlantSegue")
            if let detailVC = segue.destination as? DetailViewController, let indexPath = tableView.indexPathForSelectedRow {
                detailVC.plantController = self.plantController
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

extension PlantsTableViewController: UNUserNotificationCenterDelegate {
    
}
