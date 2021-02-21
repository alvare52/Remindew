//
//  PlantController.swift
//  Remindew
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation
import CoreData
import UserNotifications
import UIKit

class PlantController {
    
    // MARK: - Properties
        
    let calendar = Calendar.current
    
    /// "https://trefle.io/api/v1/plants/search?token="
    /// /species/ gives matching species, subspecies, varieties and /plants/ gives you only main species (without child species)
    let baseUrl = URL(string: "https://trefle.io/api/v1/species/search?token=")!
    
    /// Memory cache to store already fetched images, clears itself after it has more than 100 images
    private var loadedImages = [URL: UIImage]() {
        didSet {
            // clear cache after 100 images are stored
            if loadedImages.count > 100 {
                print("loadedImages count > 100, clearing cache")
                loadedImages.removeAll()
                print("loadedImages cleared, now = \(loadedImages)")
            }
        }
    }
    
    /// Keeps track of running downloads to cancel them later
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    /// Returns the current day date components
    var currentDayComps: DateComponents {
        let currentDateComps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday],
        from: Date())
        return currentDateComps
    }
    
    var plantSearchResults: [PlantSearchResult] = []
    var tempToken: TempToken?
    
    // MARK: - Plant CRUD
    
    /// Create a plant and then save it
    func createPlant(nickname: String, species: String, date: Date, frequency: [Int16], scientificName: String, notepad: NotePad, appearanceOptions: AppearanceOptions) -> Plant {
        
        let plant = Plant(nickname: nickname,
                          species: species,
                          water_schedule: date,
                          frequency: frequency,
                          scientificName: scientificName,
                          notes: notepad.notes,
                          mainTitle: notepad.mainTitle,
                          mainMessage: notepad.mainMessage,
                          mainAction: notepad.mainAction,
                          location: notepad.location,
                          plantIconIndex: appearanceOptions.plantIconIndex,
                          plantColorIndex: appearanceOptions.plantColorIndex,
                          actionIconIndex: appearanceOptions.actionIconIndex,
                          actionColorIndex: appearanceOptions.actionColorIndex)
     
        addRequestsForPlant(plant: plant)
        
        // if notifications are disabled, dont make plant???
        savePlant()
        return plant
    }
    
    /// Update a plant that already exists
    func update(nickname: String,
                species: String,
                water_schedule: Date,
                frequency: [Int16],
                scientificName: String,
                notepad: NotePad,
                appearanceOptions: AppearanceOptions,
                plant: Plant) {
        
        plant.nickname = nickname
        plant.species = species
        plant.water_schedule = water_schedule
        plant.frequency = frequency
        plant.scientificName = scientificName
        
        plant.notes = notepad.notes
        plant.mainTitle = notepad.mainTitle
        plant.mainMessage = notepad.mainMessage
        plant.mainAction = notepad.mainAction
        plant.location = notepad.location
        
        plant.plantIconIndex = appearanceOptions.plantIconIndex
        plant.plantColorIndex = appearanceOptions.plantColorIndex
        plant.actionIconIndex = appearanceOptions.actionIconIndex
        plant.actionColorIndex = appearanceOptions.actionColorIndex
        
        // remove pending notifications for this plant first
        removeAllRequestsForPlant(plant: plant)
        
        // then create brand new ones
        addRequestsForPlant(plant: plant)
        
        savePlant()
    }
    
    /// Update a plant that already exists when we leave notepa
    func updateInNotepad(notepad: NotePad,
                         plant: Plant) {
        
        var remakeNotifications = true
        if plant.mainTitle == notepad.mainTitle && plant.mainMessage == notepad.mainMessage {
            remakeNotifications = false
        }
        
        plant.scientificName = notepad.scientificName
        plant.notes = notepad.notes
        plant.mainTitle = notepad.mainTitle
        plant.mainMessage = notepad.mainMessage
        plant.mainAction = notepad.mainAction
        plant.location = notepad.location
        
        // check here if Title and Message are different?
        if remakeNotifications {
            // remove pending notifications for this plant first (if it needs to change title or message)
            removeAllRequestsForPlant(plant: plant)
            // then create brand new ones
            addRequestsForPlant(plant: plant)
        }
        
        savePlant()
    }
    
    /// Update plant's needsWatering status, set lastWateredDate, and save
    func updatePlantWithWatering(plant: Plant, needsWatering: Bool) {
        
        plant.needsWatering = needsWatering
        
        // if it goes from TRUE to FALSE (water plant button / leading swipe), then update last watered
        if needsWatering == false {
            plant.lastDateWatered = Date()
        }
        
        // if it goes from FALSE to TRUE, (checkWateringStatus) then leave last watered alone
        
        savePlant()
    }
    
    /// Updates and saves plant's isEnabled property. Deletes notifications if set to false, enables notifications if set to true
    func togglePlantNotifications(plant: Plant) {
        
        // toggle isEnabled (plants always start with isEnabled = true)
        plant.isEnabled.toggle()
        
        // delete plant's main notifications either way just in case
        removeAllRequestsForPlant(plant: plant)
        
        // this method only creates title, message and sound if isEnabled but badges stay regardless
        addRequestsForPlant(plant: plant)
    
        // save
        savePlant()
    }
    
    /// Deletes plant and then saves or resets if there's an error
    func deletePlant(plant: Plant) {
        
        // delete image
        UIImage.deleteImage("userPlant\(plant.identifier!)")
        
        // delete all notifications for plant
        removeAllRequestsForPlant(plant: plant)
        
        // delete ALL reminder notifications for plant
        deleteAllReminderNotificationsForPlant(plant: plant)
        
        CoreDataStack.shared.mainContext.delete(plant)
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            CoreDataStack.shared.mainContext.reset() // UN-deletes
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    /// Saves to Core Data, gets called from other methods
    func savePlant() {
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    // MARK: - Reminders CRUD
    
    /// Creates new Reminder with given paramters and adds it to given Plant then saves to main context
    func addNewReminderToPlant(plant: Plant, actionName: String, alarmDate: Date, frequency: Int16, actionTitle: String, actionMessage: String, notes: String, isEnabled: Bool, colorIndex: Int16, iconIndex: Int16) {
        
        let reminderToAdd = Reminder(actionName: actionName,
                                     alarmDate: alarmDate,
                                     frequency: frequency,
                                     actionTitle: actionTitle,
                                     actionMessage: actionMessage,
                                     colorIndex: colorIndex,
                                     iconIndex: iconIndex,
                                     isEnabled: isEnabled,
                                     notes: notes)
        
        plant.addToReminders(reminderToAdd)
        createNotificationForReminder(plant: plant, reminder: reminderToAdd)
        savePlant()
    }
    
    /// Takes in an existing Reminder, edits it, and then saves to main context
    func editReminder(reminder: Reminder, actionName: String, alarmDate: Date, frequency: Int16, actionTitle: String, actionMessage: String, notes: String, isEnabled: Bool, colorIndex: Int16, iconIndex: Int16) {
        
        // check if we need to update notification
        let shouldUpdateNotification = checkIfReminderNeedsNewNotification(reminder: reminder,
                                                                           newDate: alarmDate,
                                                                           newTitle: actionTitle,
                                                                           newMessage: actionMessage)
        
        reminder.actionName = actionName
        reminder.alarmDate = alarmDate
        reminder.frequency = frequency
        reminder.actionTitle = actionTitle
        reminder.actionMessage = actionMessage
        reminder.notes = notes
        reminder.isEnabled = isEnabled
        reminder.colorIndex = colorIndex
        reminder.iconIndex = iconIndex
        
        // only update notification if title, message, or date have been changed
        if shouldUpdateNotification {
            updateNotificationForReminder(reminder: reminder)
        }
        
        savePlant()
    }
    
    /// Edits Reminder's lastDate and alarmDate (for when completing task and updating new alarmDate)
    func updateReminderDates(reminder: Reminder) {
        
        reminder.lastDate = Date()
        reminder.alarmDate = reminder.alarmDate?.addingTimeInterval(86400 * Double(reminder.frequency))
        // create new notification? (and delete old just in case)
        deleteReminderNotificationForPlant(reminder: reminder, plant: reminder.plant!)
        createNotificationForReminder(plant: reminder.plant!, reminder: reminder)
        savePlant()
    }
    
    /// Returns a bool based on if a plant has a reminder that needs need attention
    func plantRemindersNeedAttention(plant: Plant) -> Bool {
                
        for reminder in plant.reminders?.allObjects as! Array<Reminder> {
            if reminder.alarmDate! <= Date() {
                print("PLANT: \(plant.nickname!) NEEDS ATTENTION: \(reminder.actionName!)")
                return true
            }
        }
        
        return false
    }

    /// Updates and saves reminder's isEnabled property. Deletes notifications if set to false or enables notifications if set to true
    func toggleReminderNotification(plant: Plant, reminder: Reminder) {
        
        // toggle isEnabled (Reminders always start with isEnabled = true)
        reminder.isEnabled.toggle()
        
        // delete reminder notification either way just in case
        deleteReminderNotificationForPlant(reminder: reminder, plant: plant)
        
        // this method only creates title, message and sound if isEnabled but badges stay regardless
        createNotificationForReminder(plant: plant, reminder: reminder)
        
        savePlant()
    }
    
    /// Removes reminder from plant.reminders, deletes reminder from core data then saves or resets if there's an error
    func deleteReminderFromPlant(reminder: Reminder, plant: Plant) {
        
        // remove Reminder from Plant
        plant.removeFromReminders(reminder)
        
        // remove Reminder's Notification
        deleteReminderNotificationForPlant(reminder: reminder, plant: plant)
        
        CoreDataStack.shared.mainContext.delete(reminder)
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            CoreDataStack.shared.mainContext.reset() // UN-deletes
            NSLog("Error saving managed object context (reminder): \(error)")
        }
    }
    
    // MARK: - Helpers
    
    /// When getting back temp token, set lastDateTokenGrabbed
    /// Checks Date() and lastDayTokenSet (Date), returns true if time between the two
    /// is greater than 24 hours
    func newTempTokenIsNeeded() -> Bool {
        
        // only return false if it hasn't been 24 hours (or more) since last token was grabbed
        if let lastDate = UserDefaults.standard.object(forKey: .lastDateTokenGrabbed) as? Date {
            // if timeinterval is < 85000, then return false (86400 secs in 24 hours, 85000 just in case)
            if Date().timeIntervalSince(lastDate) < 85000 {
                print("Time interval since Date() = \(Date().timeIntervalSince(lastDate)) is less then 85000")
                print("no new temp token needed, quitting early and returning false")
                return false
            }
        }
        // return true if lastDate was never set or it's been more than 24 hours
        return true
    }
    
    /// Prints out last temp token grabbed and the date it was set (call in viewDidLoad )
    func printLastTokenAndDate() {
        
        if let lastToken = UserDefaults.standard.string(forKey: .lastTempToken) {
            print("lastToken = \(lastToken)")
        } else {
            print("lastToken = nil")
        }
        if let lastDate = UserDefaults.standard.object(forKey: .lastDateTokenGrabbed) as? Date {
            print("currDate = \(DateFormatter.lastWateredDateFormatter.string(from: Date()))")
            print("lastDate = \(DateFormatter.lastWateredDateFormatter.string(from: lastDate))")
        } else {
            print("lastDate = nil")
        }
    }
    
    // MARK: - Notification Center
    
    /// Returns array of Strings that are the plant's notification identifiers (weekday + UUID)
    func returnPlantNotificationIdentifiers(plant: Plant) -> [String] {
        print("returnPlantNotificationIdentifiers")
        var result = [String]()
        
        for i in 1...7 {
            result.append("\(i)\(plant.identifier!)")
        }
        
        print("all notes for plant to remove = \(result)")
        return result
    }
        
    /// Returns a [Date] made up of selected weekdays and plant watering schedule (time)
    func makeDateCompsForSchedule(weekday: Int16, time: Date) -> DateComponents {
        print("makeDateCompFromSchdule")
        let day = Int(weekday)
        let timeComps = calendar.dateComponents([.hour, .minute], from: time)
        var dateComps = DateComponents()
        dateComps.hour = timeComps.hour
        dateComps.minute = timeComps.minute
        dateComps.weekday = day
        // date from dateComps is inaccurate but not really needed for this right now
        return dateComps
    }
    
    /// Adds notification requests for all days the plant needs to be watered (called inside of addRequestsForPlant)
    func makeAllRequestsForPlant(plant: Plant) {
        print("makeAllRequestsForPlant")
        
        for day in plant.frequency! {

            // identifier
            let identifier = "\(day)\(plant.identifier!)"

            // content
            let content = UNMutableNotificationContent()
            
            // only make sound, title, and message if plant.isEnabled so we still get badges if disabled
            if plant.isEnabled {
                
                // 1. Sound
                // TODO: use custom sound later?
//                content.sound = .default
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "bell_chime_3.mp3"))
                
                // 2. Title
                var title = NSLocalizedString("Time to water your plant!", comment: "Title for notification")
                // only use custom title if it's not nil and its not an empty string
                if plant.mainTitle != nil && plant.mainTitle != "" {
                    title = plant.mainTitle!
                }
                content.title = "\(title)"

                // 3. Message
                var message = "\(plant.nickname!) " + NSLocalizedString("needs water.", comment: "plant.nickname needs water.")
                // only use custom message if it's not nil and its not an empty string
                if plant.mainMessage != nil && plant.mainMessage != "" {
                    message = plant.mainMessage!
                }
                content.body = message
            }
            
            // 4. Badge
            content.badge = 1

            // 5. Trigger
            let date = makeDateCompsForSchedule(weekday: day, time: plant.water_schedule!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

            // 6. Request
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    NSLog("Error adding notification: \(error)")
                }
            }
        }
    }
    
    /// Checks to see if notifications are allowed first, then adds all requests (by calling makeAllRequestsForPlant)
    func addRequestsForPlant(plant: Plant) {
        print("addRequestsForPlant")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            switch granted {
            case true:
                print("PERMISSION GRANTED")
                DispatchQueue.main.async {
                    print("ASYNC: Attempting to add all requests")
                    self.makeAllRequestsForPlant(plant: plant)
                }
            case false:
                print("permission NOT granted, please allow notifications")
                return
            }
        }
    }
    
    /// Removes all pending notifications for plant
    func removeAllRequestsForPlant(plant: Plant) {
        // get all identifiers for this plant [String]
        let notesToRemove = returnPlantNotificationIdentifiers(plant: plant)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notesToRemove)
        
        UNUserNotificationCenter.checkPendingNotes { result in
            DispatchQueue.main.async {
                print("Pending Notifications = \(result)")
            }
        }
    }
    
    /// Checks if notifications are allowed then creates notification for given Reminder
    func createNotificationForReminder(plant: Plant, reminder: Reminder) {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            switch granted {
            case true:
                print("PERMISSION GRANTED")
                DispatchQueue.main.async {
                    print("ASYNC: Attempting to add all requests")
                    self.makeReminderNotificationForPlant(reminder: reminder, plant: plant)
                }
            case false:
                print("permission NOT granted, please allow notifications")
                return
            }
        }
    }
    
    /// Creates a Notification using a Reminder's UUID and a Plant's UUID
    func makeReminderNotificationForPlant(reminder: Reminder, plant: Plant) {
        
        let identifier = "\(reminder.identifier!)\(plant.identifier!)"
        
        // content
        let content = UNMutableNotificationContent()
        
        // only make sound, title and message if reminder.isEnabled but we still keep badges
        if reminder.isEnabled {
//            content.sound = .default
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "bell_chime_1.mp3"))

            // title
            var title = NSLocalizedString("Time to water your plant!", comment: "Title for notification")
            // only use custom title if it's not nil and its not an empty string
            if reminder.actionTitle != nil && reminder.actionTitle != "" {
                title = reminder.actionTitle!
            }
            content.title = "\(title)"
            
            // message
            var message = "\(plant.nickname!) " + NSLocalizedString("needs water.", comment: "plant.nickname needs water.")
            // only use custom message if it's not nil and its not an empty string
            if reminder.actionMessage != nil && reminder.actionMessage != "" {
                message = reminder.actionMessage!
            }
            content.body = message
        }
        
        // badge
        content.badge = 1

        // trigger
        let dateComps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.alarmDate!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                NSLog("Error adding reminder notification: \(error)")
            }
        }
    }
    
    /// Checks if a Reminder's Notification needs to be changed
    func checkIfReminderNeedsNewNotification(reminder: Reminder, newDate: Date, newTitle: String, newMessage: String) -> Bool {
        
        guard let oldTitle = reminder.actionTitle, let oldMessage = reminder.actionMessage, let oldDate = reminder.alarmDate else {
            return false
        }
        
        // make sure title, message, or date are not the same
        guard newTitle != oldTitle || newMessage != oldMessage || newDate != oldDate else { return false }
        
        return true
    }
    
    /// Updates notification for given Reminder by first deleting it and creating new one
    func updateNotificationForReminder(reminder: Reminder) {
        deleteReminderNotificationForPlant(reminder: reminder, plant: reminder.plant!)
        createNotificationForReminder(plant: reminder.plant!, reminder: reminder)
    }
    
    /// Deletes a Reminder's Notification using the identifier made from its UUID and it's Plant's UUID
    func deleteReminderNotificationForPlant(reminder: Reminder, plant: Plant) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(reminder.identifier!)\(plant.identifier!)"])
    }
    
    /// Deletes ALL Reminder Notifications for given Plant (called when Plant is deleted)
    func deleteAllReminderNotificationsForPlant(plant: Plant) {
        
        let remindersArray = plant.reminders?.allObjects as! Array<Reminder>
        for reminder in remindersArray {
            deleteReminderNotificationForPlant(reminder: reminder, plant: plant)
        }
    }
    
    // MARK: - Network Calls
    
    /// Sign Secret Token to get a temporary one for the user and set it to self.tempToken or returns a NetworkError
    /// Only do this ONCE a day
    func signToken(completion: @escaping (Result<String,NetworkError>) -> Void) {
        print("signToken called")
        
        let baseUrl = "https://trefle.io/api/auth/claim?token="
        let websiteUrl = "https://github.com/alvare52/Remindew"

        // URL
        guard let signUrl = URL(string: "\(baseUrl)\(secretToken)&origin=\(websiteUrl)") else {
            print("invalid token")
            completion(.failure(.invalidToken))
            return
        }
        
        print("signUrl = \(signUrl)")
        
        var request = URLRequest(url: signUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Does not require body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("otherError in signToken \(error)")
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                print("status code = \(response.statusCode)")
                completion(.failure(.serverDown))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                self.tempToken = try decoder.decode(TempToken.self, from: data)
                // set new temp token and timestamp for it to check before calling this method again
                UserDefaults.standard.set(self.tempToken?.token, forKey: "lastTempToken")
                UserDefaults.standard.set(Date(), forKey: "lastDateTokenGrabbed")
                print("self.tempToken now = \(String(describing: self.tempToken))")
            } catch {
                print("Error decoding temp token object: \(error)")
                completion(.failure(.noDecode))
                return
            }
            
            completion(.success("New token/timestamp set to user default")) // no error
        }.resume()
    }
    
    /// Takes in a search term. Returns either an array of PlantSearchResult or a NetworkError
    func searchPlantSpecies(_ searchTerm: String, completion: @escaping (Result<[PlantSearchResult],NetworkError>) -> Void = { _ in }) {

        print("searchPlantSpecies called")
        
        // No token (non-temp one)
        guard let token = UserDefaults.standard.string(forKey: .lastTempToken) else {
            print("userdefault lastTempToken string is nil in searchPlantSpecies")
            completion(.failure(.noToken))
            return
        }
        
        // URL REQUEST
        guard let requestUrl = URL(string: "\(baseUrl)\(token)&q=\(searchTerm)") else {
            print("invalid url")
            completion(.failure(.invalidURL))
            return
        }
        
        print("requestURL = \(requestUrl)")
        var request = URLRequest(url: requestUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
        URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let error = error {
                print("Error fetching searched plants: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherError))
                }
                return
            }

            guard let data = data else {
                print("No data return by data task")
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                print("status code = \(response.statusCode)")
                completion(.failure(.serverDown))
                return
            }
        
            let jsonDecoder = JSONDecoder()

            do {
                let plantSearchResultsDataArray = try jsonDecoder.decode(PlantData.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(plantSearchResultsDataArray.data))
                }
            } catch {
                print("Error decoding or storing searched plants \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.noDecode))
                }
            }
        }.resume()
    }
    
    /// Fetches image from URL, returns default image if url is invalid, returns image in cache if image already fetched
    func loadImage(_ url: URL?, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        
        /// If there are any errors fetching an image, this image is returned instead
        let defaultImage = UIImage.logoImage

        guard let url = url else {
            print("can not make url from passed in string")
            completion(.success(defaultImage))
            return nil
        }
        
        // check if image at url is already in our cache, return nil since task wasn't made yet
        if let image = loadedImages[url] {
            completion(.success(image))
            return nil
        }
        
        // used to identify the task we're about to make
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // removes running task before we leave scope of the task's completion handler
            defer {
                self.runningRequests.removeValue(forKey: uuid)
            }
            
            // if there's data and we can get an image out of it, return it in completion
            if let data = data, let image = UIImage(data: data) {
                self.loadedImages[url] = image
                completion(.success(image))
                return
            }
            
            // check for error and do something with it
            guard let error = error else {
                // without an image or an error, we'll just ignore this for now
                // you could add your own special error cases for this scenario
                return
            }
            
            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.failure(error))
                return
            }
            
            // the request was cancelled, no need to call the callback
        }
        task.resume()
        
        // add request to dictionary, then return to caller
        runningRequests[uuid] = task
        
        return uuid
    }
    
    /// Uses given UUID to find a running data task and cancels it.
    /// Then removes task from running requests if it exists
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}
