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
    func createPlant(nickname: String, species: String, date: Date, frequency: [Int16]) -> Plant {
        print("createPlant")
        let plant = Plant(nickname: nickname, species: species, water_schedule: date, frequency: frequency)
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
    func update(nickname: String, species: String, water_schedule: Date, frequency: [Int16], plant: Plant) {
        plant.nickname = nickname
        plant.species = species
        plant.water_schedule = water_schedule
        plant.frequency = frequency
        
        // remove pending notifications for this plant first
        print("removing")
        removeAllRequestsForPlant(plant: plant)
        // then create brand new ones
        print("adding new ones, \(String(describing: plant.frequency?.count))")
        addRequestsForPlant(plant: plant)
        
        savePlant()
    }
    
    /// Called after reminder goes off so it doesn't keep going off
    func updatePlantWithWatering(plant: Plant, needsWatering: Bool) {
        plant.needsWatering = needsWatering
        // if it goes from TRUE to FALSE, then update last watered
        if needsWatering == false {
            plant.lastDateWatered = Date()
        }
        // if it goes from FALSE to TRUE, then leave last watered alone
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
    
    // Returns a string of all days selected separated by a space
    func returnDaysString(plant: Plant) -> String {
        
        var result = [String]()
        
        for day in plant.frequency! {
            // [1,2,3,7]
            result.append("\(DaySelectionView.dayInitials[Int(day - 1)])")
        }
        
        // if everyday basically
        if result.count == 7 {
            return "Every day"
        }
        return result.joined(separator: " ")
    }
    
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
            content.title = "WATER YOUR PLANT!"
            content.body = "\(plant.nickname!) needs water."

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
    
    /// Save image to documents directory, and remove old one if it exists and save new one
    /// - Parameter imageName: the name of an image that has been saved
    /// - Parameter image: the UIImage you want to save
    func saveImage(imageName: String, image: UIImage) {
        print("saveImage")
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        print("\(image.size) IMAGE SIZE")
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }

        }

        do {
            try data.write(to: fileURL)
            print("Success saving image")
        } catch let error {
            print("error saving file with error", error)
        }

    }

    /// Takes in the name of a stored image and returns a UIImage or nil if it can't find one
    func loadImageFromDiskWith(fileName: String) -> UIImage? {

        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            print("Success loading image")
            return image
        }

        return nil
    }
    
    /// Resize image to given dimensions
     func resizeImage(image: UIImage) -> UIImage {
        print("\(image.size) IMAGE STARTS AS THIS")
        let newWidth: CGFloat = 1024.0 // ? check if image is too big first, then scale down if need be
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print("\(newImage!.size) IMAGE SIZE RESCALED TO THIS")
        return newImage!
    }
    
    let baseUrl = URL(string: "https://trefle.io/api/v1/plants/search?token=")!
    
    /// Takes in a search term and assigns local results array to those results
    func searchPlantSpecies(_ searchTerm: String, completion: @escaping (Error?) -> Void = { _ in }) {

        print("searchPlantSpecies called")
        
        // URL REQUEST
        // TODO: CRASHES IF THERE'S A SPACE IN THE SEARCH TERM
        let requestUrl = URL(string: "\(baseUrl)\(secretToken)&q=\(searchTerm)")!
        print("requestURL = \(requestUrl)")
        var request = URLRequest(url: requestUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
        URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let error = error {
                print("Error fetching searched plants: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }

            guard let data = data else {
                print("No data return by data task")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                return
            }

            let jsonDecoder = JSONDecoder()

            do {
                let plantSearchResultsDataArray = try jsonDecoder.decode(PlantData.self, from: data)
                self.plantSearchResults = plantSearchResultsDataArray.data
//                print("\(self.plantSearchResults.count) items received")
//                print("\(self.plantSearchResults)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print("Error decoding or storing searched plants \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }.resume()
    }
    
    /// Sign Secret Token to get a temporary one for the user and set it to self.tempToken
    /// Only do this ONCE a day
    func signToken(completion: @escaping (Error?) -> Void) {
        print("signToken called")
        
        let baseUrl = "https://trefle.io/api/auth/claim?token="
        let websiteUrl = "https://docs.trefle.io/docs/advanced/client-side-apps"
        let signUrl = URL(string: "\(baseUrl)\(secretToken)&origin=\(websiteUrl)")!
        print("signUrl = \(signUrl)")
        
        var request = URLRequest(url: signUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
    
        // Does not require body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            do {
                self.tempToken = try decoder.decode(TempToken.self, from: data)
                print("self.tempToken now = \(self.tempToken)")
            } catch {
                print("Error decoding temp token object: \(error)")
                completion(error)
                return
            }
            
            completion(nil) // no error
        }.resume()
    }
    
    /// Fetches image at url given or returns default image if no url
    func fetchImage(with url: URL?, completion: @escaping (UIImage?) -> Void = { _ in }) {

        /// If there are any errors fetching an image, this image is returned instead
        let defaultImage = UIImage(named: "plantslogoclear1024x1024")

        guard let url = url else {
            print("cant make url from passed in string")
            completion(defaultImage)
            return
        }

        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching image: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(defaultImage)
                return
            }
            
            let imageToReturn = UIImage(data: data)
            completion(imageToReturn)
        }.resume()
    }
}


struct PlantData: Decodable {
    let data: [PlantSearchResult]
}

struct PlantSearchResult: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case commonName = "common_name"
        case scientificName = "scientific_name"
        case imageUrl = "image_url"
    }
    
    let commonName: String?
    let scientificName: String?
    let imageUrl: URL?
}

struct TempToken: Decodable {
    let token: String?
    let expiration: String?
}

let secretToken = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo5NzI0LCJvcmlnaW4iOiJodHRwczovL2RvY3MudHJlZmxlLmlvL2RvY3MvYWR2YW5jZWQvY2xpZW50LXNpZGUtYXBwcyIsImlwIjpudWxsLCJleHBpcmUiOiIyMDIwLTEyLTAzIDE5OjQ1OjEyICswMDAwIiwiZXhwIjoxNjA3MDI0NzEyfQ.odFPGyOo-lxGn7oaPkvJNIpSON70vOLlIAZPdphQ_bw"
