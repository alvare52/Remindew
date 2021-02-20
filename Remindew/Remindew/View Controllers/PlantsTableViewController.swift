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
        AudioServicesPlaySystemSound(SystemSoundID(1104))
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        performSegue(withIdentifier: "AddPlantSegue", sender: self)
    }
    
    // MARK: - Properties
    
    /// Fetches Plant objects from storage
    lazy var fetchedResultsController: NSFetchedResultsController<Plant> = {
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        
        print("FetchedResultsController fetching now")
        
        // default is to sort by nickname
        var sortKey = "nickname"
        var secondaryKey = "species"
        
        // if we DO sort by species instead of nickname, do the following
        if UserDefaults.standard.bool(forKey: .sortPlantsBySpecies) {
            print("Sorting by species instead")
            sortKey = "species"
            secondaryKey = "nickname"
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "location", ascending: true),
                                        NSSortDescriptor(key: sortKey, ascending: true),
                                        NSSortDescriptor(key: secondaryKey, ascending: true)]


        let context = CoreDataStack.shared.mainContext

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: "location",
                                             cacheName: nil)
        frc.delegate = self
        try! frc.performFetch() // do it and crash if you have to
        return frc
    }()
    
    let plantController = PlantController()
    let calendar = Calendar.current
    private var observer: NSObjectProtocol?
    let refreshWheel = UIRefreshControl()
    
    /// Number of plants that need water or reminder completion. didSet updates title and badge count
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
        
        UIColor().updateToDarkOrLightTheme()
        
        // refresh control
        tableView.refreshControl = refreshWheel
        refreshWheel.tintColor = .mixedBlueGreen
        refreshWheel.addTarget(self, action: #selector(checkIfPlantsNeedWatering), for: .valueChanged)
        
        // Listen for when to check watering status of plants (posted when notification comes in while app is running)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkIfPlantsNeedWatering),
                                               name: .checkWateringStatus,
                                               object: nil)
        
        // Listen to see if we need to update the sorting (posted when sorting setting is changed)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateSorting),
                                               name: .updateSortDescriptors,
                                               object: nil)
        
        // give nav bar its date
        dateLabel.title = DateFormatter.navBarDateFormatter.string(from: Date())
        
        // starts as disabled and this lets it keep its mixedBlueGreen color
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
    
    // MARK: - Helpers
    
    // TODO: Move to AlertController Extension?
    /// Presents an alert asking user if they're sure if they want to delete the plant they swiped on
    private func deletionWarningAlert(plant: Plant) {
        
        guard let plantNickname = plant.nickname else { return }
        let title = NSLocalizedString("Delete Plant",
                                      comment: "Title Plant Deletion Alert")
        let message = NSLocalizedString("Would you like to delete ",
                                        comment: "Message for when nickname is missing in textfield") + "\(plantNickname)?" + "\n" + NSLocalizedString("This can not be undone.", comment: "Deletion can't be undone")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
        // Cancel
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Plant Deletion Option"), style: .default)
        
        // Delete
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete Plant Option"), style: .destructive) { _ in
            self.plantController.deletePlant(plant: plant)
            self.checkIfPlantsNeedWatering()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// When sort setting is set, run this to update the table view's sort descriptor
    @objc func updateSorting() {
        print("upateSorting")
        
        // sort by nickname, unless sort by species is turned on
        var sortKey = "nickname"
        var secondaryKey = "species"
        
        // if we DO sort by species instead of nickname, do the following
        if UserDefaults.standard.bool(forKey: .sortPlantsBySpecies) {
            print("Sorting by species instead")
            sortKey = "species"
            secondaryKey = "nickname"
        }
        
        // set sort descriptors
        fetchedResultsController.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "location", ascending: true),
                                                                 NSSortDescriptor(key: sortKey, ascending: true),
                                                                 NSSortDescriptor(key: secondaryKey, ascending: true)]
        
        // try to perform fetch
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("fetch failed in updateSorting")
        }
    }
    
    /// Goes through all plants and checks if they need watering today. Also updates title based on how many need water or reminder completion
    @objc private func checkIfPlantsNeedWatering() {
        print("checkIfPlantNeedsWatering")
        
        // for tallying up all plants that need watering
        var count = 0
        
        // each plant if it's next water date has passed
        for plant in fetchedResultsController.fetchedObjects! {
            
            // TODO: make method that does this in Plant or PlantController?
            // TODO: move outside of loop?
            // get current weekday from calendar first
            let currentDayComps = calendar.dateComponents([.day, .hour, .minute, .second, .weekday], from: Date())
            let currentWeekday = Int16(currentDayComps.weekday!)
            let currentHour = currentDayComps.hour!
            let currentMinute = currentDayComps.minute!
            let currentDay = currentDayComps.day!
            
            // if today is one of the selected days for this plant
            if let _ = plant.frequency!.firstIndex(of: currentWeekday) {
                
                // now check if plant.water_schedule time is <= currentMinute and
                let plantComps = calendar.dateComponents([.hour, .minute, .second], from: plant.water_schedule!)
                let plantHour = plantComps.hour!
                let plantMinute = plantComps.minute!
            
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
                    
                    // only reload if something needs watering (might change back later)
//                    tableView.reloadData()
                    
                }
                
            }

            // count all plants that need watering for title display
            if plant.needsWatering { count += 1 }
            
            if plantController.plantRemindersNeedAttention(plant: plant) {
                count += 1
            }
        }
        
        // update counter
        plantsThatNeedWaterCount = count
        
        // update date label since it needs to be updated at least once a day to display correct date
        dateLabel.title = DateFormatter.navBarDateFormatter.string(from: Date())
        
        // so reminderButton can be updated
        tableView.reloadData()
        
        // stop refresh animation (starts refreshing when its called)
        refreshWheel.endRefreshing()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return nil
        }
        // TODO: should check for sortKey here?
        return sectionInfo.name.capitalized
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = .customBackgroundColor
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .darkGray
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath) as? PlantsTableViewCell else {
            return UITableViewCell()
        }
        cell.plant = fetchedResultsController.object(at: indexPath)
        return cell
    }
    
    // Right swipe to complete main action / show lastWatered date
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let plant = fetchedResultsController.object(at: indexPath)
        
        // Complete task
        let completeTask = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            print("Completed \(plant.mainAction ?? "water") \(plant.nickname!)")
            if plant.needsWatering {
                self.plantController.updatePlantWithWatering(plant: plant, needsWatering: false)
                // so tableView can refresh with new main title
                self.plantsThatNeedWaterCount -= 1
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            completion(true)
        }
        
        var lastCompletedString = DateFormatter.lastWateredDateFormatter.string(from: plant.lastDateWatered ?? Date())
        if plant.lastDateWatered == nil {
            lastCompletedString = NSLocalizedString("Brand New Plant", comment: "plant that hasn't been watered yet")
        }
        
        completeTask.image = plant.needsWatering ? UIImage.iconArray[Int(plant.actionIconIndex)] : UIImage(systemName: "clock.arrow.circlepath")
        completeTask.title = plant.needsWatering ? "\(plant.mainAction ?? "Water")" : lastCompletedString
        completeTask.backgroundColor = UIColor.colorsArray[Int(plant.actionColorIndex)]
        
        let config = UISwipeActionsConfiguration(actions: [completeTask])
        config.performsFirstActionWithFullSwipe = plant.needsWatering ? true : false
                
        return config
    }
    
    /// Give cell 2 options when swiping from right to left (silence notification and delete)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let plant = fetchedResultsController.object(at: indexPath)
        
        // Delete
        let delete = UIContextualAction(style: .destructive, title: "") { (action, view, completion) in
            print("Deleted \(plant.nickname!)")
            self.deletionWarningAlert(plant: plant)
            completion(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
        
        // Silence
        let silence = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            print("Silenced \(plant.nickname!)")
            self.plantController.togglePlantNotifications(plant: plant)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            completion(true)
        }
        silence.image = plant.isEnabled ? UIImage(systemName: "bell.slash.fill") : UIImage(systemName: "bell.fill")
        silence.backgroundColor = .systemIndigo
        
        let config = UISwipeActionsConfiguration(actions: [delete, silence])
        config.performsFirstActionWithFullSwipe = false
                
        return config
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
        
        // SettingsPageViewController
        if segue.identifier == "ShowSettingsSegue" {
            print("ShowSettingsSegue")
            if let settingsVC = segue.destination as? SettingsPageViewController {
                settingsVC.totalPlantCount = fetchedResultsController.fetchedObjects?.count ?? 0
                settingsVC.totalLocationsCount = fetchedResultsController.sectionIndexTitles.count
            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

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
            tableView.reloadRows(at: [indexPath], with: .right)
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
