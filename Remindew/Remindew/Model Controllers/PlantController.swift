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

/// Custom Errors to provide better error messages
enum NetworkError: Error {
    case noAuth
    case badAuth
    case otherError
    case badData
    case noDecode
    case noEncode
    case noToken
    case invalidURL
    case noData
    case invalidToken
    case serverDown
}

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
    
    // MARK: - Create, Read, Update, Delete, Save plants
    
    /// Create a plant and then save it
    func createPlant(nickname: String, species: String, date: Date, frequency: [Int16], scientificName: String, notepad: NotePad) -> Plant {
        print("createPlant")
        let plant = Plant(nickname: nickname,
                          species: species,
                          water_schedule: date,
                          frequency: frequency,
                          scientificName: scientificName,
                          notes: notepad.notes,
                          mainTitle: notepad.mainTitle,
                          mainMessage: notepad.mainMessage,
                          mainAction: notepad.mainAction,
                          location: notepad.location)
        print("plant schedule: \(String(describing: plant.water_schedule))")
        print("plant frequency: \(String(describing: plant.frequency))")
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        
//        makeAllRequestsForPlant(plant: plant)
        addRequestsForPlant(plant: plant)
        
        // if notes are disable, dont make plant???
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
        
        // remove pending notifications for this plant first
        print("removing")
        removeAllRequestsForPlant(plant: plant)
        // then create brand new ones
        print("adding new ones, \(String(describing: plant.frequency?.count))")
        addRequestsForPlant(plant: plant)
        
        savePlant()
    }
    
    /// Update a plant that already exists when we leave notepa
    func updateInNotepad(notepad: NotePad,
                         plant: Plant) {
        
        var remakeNotifications = true
        if plant.mainTitle == notepad.mainTitle && plant.mainMessage == notepad.mainMessage {
            print("mainTitle and mainMessage are same as before, so DONT update reminders")
            remakeNotifications = false
        }
        
        plant.scientificName = notepad.scientificName
        plant.notes = notepad.notes
        plant.mainTitle = notepad.mainTitle
        plant.mainMessage = notepad.mainMessage
        plant.mainAction = notepad.mainAction
        plant.location = notepad.location
        
        // TODO: check here if Title and Message are different?
        if remakeNotifications {
            // remove pending notifications for this plant first (if it needs to change title or message)
            print("removing")
            removeAllRequestsForPlant(plant: plant)
            // then create brand new ones
            print("adding new ones, \(String(describing: plant.frequency?.count))")
            addRequestsForPlant(plant: plant)
        }
        
        savePlant()
    }
    
    /// Called after reminder goes off so it doesn't keep going off
    func updatePlantWithWatering(plant: Plant, needsWatering: Bool) {
        
        plant.needsWatering = needsWatering
        
        // if it goes from TRUE to FALSE (water plant button clicked), then update last watered
        if needsWatering == false {
            plant.lastDateWatered = Date()
        }
        
        // if it goes from FALSE to TRUE, then leave last watered alone (checkWateringStatus)
        
        savePlant()
    }
    
    /// Deletes plant and then saves or resets if there's an error
    func deletePlant(plant: Plant) {
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
    
    /// Uses selected days (mandatory) to set the plant's NEXT date for watering
    func returnWateringSchedule(plantDate: Date, days: [Int16]) -> Date {
        print("returnWateringSchedule")
        let val = calculateNextWateringValue(days)
        if let result = calendar.date(byAdding: .day, value: val, to: Date()) {
            return result
        }
        
        print("Error making next watering schedule in setWateringSchedule")
        return Date()
    }
    
    /// Returns first date a plant reminder will go off. Made of a Weekday,  Hour and Minutes
    /// - Parameter days: Array of selected days when the reminders should go off
    /// - Parameter time: The "Date" that we will grab only the hours and minutes from
    func createDateFromTimeAndDay(days: [Int16], time: Date) -> Date {
        print("createDateFromTimeAndDay")
        var result = Date()
        
        let plantTimeComps = calendar.dateComponents([.hour, .minute, .weekday], from: time)
        
        let cur = currentDayComps.weekday!
        
        // If today IS in the array of days
    
        if days.firstIndex(of: Int16(cur)) != nil {
            
            // if today is also a selected day, check if the time has past
            
            // if selected time is GREATER than current time (later today, so if == go else)
            if plantTimeComps.hour! >= currentDayComps.hour! && plantTimeComps.minute! > currentDayComps.minute! {
                print("first watering is later today")
                var comps = currentDayComps
                comps.hour = plantTimeComps.hour!
                comps.minute = plantTimeComps.minute!
                guard let unwrappedDate = calendar.date(from: comps) else {
                    NSLog("Error in createDateFromTimeAndDay, returnind Date 5 from now")
                    return Date(timeIntervalSinceNow: 5)
                }
                return unwrappedDate
            }
        }
            
        // Today is NOT in array of selected days
        // OR selected time is LESS than current time (next week)
        // date and time should be set using returnNextWateringSchedule
        
        // get next day alarm will go off (calcNext doesn't work in this case)
        result = returnWateringSchedule(plantDate: time, days: days)
        
        var newComps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday],
                                               from: result)
        newComps.hour = plantTimeComps.hour!
        newComps.minute = plantTimeComps.minute!
        // add plantcomsp hour and minutes to this ^
        guard let unwrappedDate = calendar.date(from: newComps) else {
            NSLog("Error in createDateFromTimeAndDay, returnind Date 5 from now")
            return Date(timeIntervalSinceNow: 5)
        }
        
        return unwrappedDate
    }
    
    /// Takes in array of weekday Int16s and returns the amount of days until next watering
    /// - Parameter daysSelected: Array of Int16, where each one corresponds to a day of the week
    func calculateNextWateringValue(_ daysSelected: [Int16]) -> Int {
        
        let cur = Int16(currentDayComps.weekday!) // 4 Wednesday
        let dayz = daysSelected //plant.frequency! // []
        var nextDay = Int16(0)
        var val = Int16(0)
        
        // returns nil if there's no number in that array
        // [3,5] but we're on wed 4
        // go through [1,3,5] etc and return index of todays int (return nil if not in array)
        // cur IS in dayz
        if let currIndex = dayz.firstIndex(of: cur) {
            
            // if last or only element in array, go back
            if (currIndex + 1) == dayz.count {
                nextDay = dayz[0]
            }
            else {
                nextDay = dayz[currIndex + 1]
            }
            
            // 5 > 3
            if nextDay > cur {
                val = nextDay - cur
            }
            // 2 < 3
            else if nextDay < cur {
                let temp = cur - nextDay
                val = 7 - temp
                
            }
            // 3 == 3
            else {
                val = 7
            }
        }
        
        // cur is NOT in dayz
        else {
            print("currIndex NOT in daysSelected -> \(dayz), cur day int is \(cur)")
            if cur > dayz.max()! {
                nextDay = cur - dayz.min()!
                val = Int16(7) - nextDay
            } else {
                for day in dayz {
                    if day > cur {
                        val = day - cur
                        break
                    }
                }
            }
        }
        
        // current day = 3, next is plant.getNextDay()
        print("cur = \(cur) nextDay = \(nextDay) val = \(val)")
        return Int(val)
    }
    
    /// When getting back temp token, set lastDateTokenGrabbed
    /// Checks Date() and lastDayTokenSet (Date), returns true if time between the two
    /// is greatere than 24 hours?
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
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.dateStyle = .medium
            print("currDate = \(formatter.string(from: Date()))")
            print("lastDate = \(formatter.string(from: lastDate))")
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
    
    /// Adds notification requests for all days the plant needs to be watered
    func makeAllRequestsForPlant(plant: Plant) {
        print("makeAllRequestsForPlant")
        
        for day in plant.frequency! {

            // identifier
            let identifier = "\(day)\(plant.identifier!)"

            // content
            let content = UNMutableNotificationContent()
            content.sound = .default
            content.title = NSLocalizedString("Time to water your plant!", comment: "Title for notification")//"Time to water your plant!"
            let bodyString = "\(plant.nickname!) " + NSLocalizedString("needs water.", comment: "plant.nickname needs water.")
            content.body = bodyString//"\(plant.nickname!) needs water."
            
            // badge
            content.badge = 1

            // trigger
            let date = makeDateCompsForSchedule(weekday: day, time: plant.water_schedule!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    NSLog("Error adding notification: \(error)")
                }
            }
        }
    }
    
    /// Checks to see if notifications are allowed first, then adds all requests
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
        
        checkPendingNotes()
    }
    
    /// Testing to see which notes are pending
    func checkPendingNotes() {
        print("checkPendingNotes")
        // check all pending ones to make sure?
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notes) in
            DispatchQueue.main.async {
                print("pending notes count = \(notes.count), notes = \(notes)")
                print("pending count = \(notes.count)")
            }
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
