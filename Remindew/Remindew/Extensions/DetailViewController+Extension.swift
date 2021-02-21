//
//  DetailViewController+Extension.swift
//  Remindew
//
//  Created by Jorge Alvarez on 2/20/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UITextFieldDelegate

extension DetailViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // only do the following when in "add mode"
        if let _ = plant { return }
        if textField == nicknameTextField {
        }
        
        else if textField == speciesTextField {

        }
    }

    /// Go to SearchViewController if tapping Search or select speciesTextfield if tapping return in nicknameTextfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Clicked "Search" in species textfield
        if textField == speciesTextField {
            
            textField.resignFirstResponder()
            
            // Go to SearchViewController
            presentSearchViewController()
            return true
        }

        // Clicked "Return" in nickname textfield
        if textField == nicknameTextField {
            
            // go to next textfield (species)
            speciesTextField.becomeFirstResponder()
        }

        return true
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

/// For accessing the photo library
extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Picked Image")
        
        // .editedImage instead? (used to say .originalImage)
        if let image = info[.editedImage] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel")
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let reminderCell = resultsTableView.dequeueReusableCell(withIdentifier: "ResultsCell", for: indexPath) as? ReminderTableViewCell else { return UITableViewCell() }

        reminderCell.reminder = reminders[indexPath.row]
        reminderCell.plantController = plantController
        reminderCell.reminderDelegate = self

        return reminderCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        let reminderCell = tableView.cellForRow(at: indexPath) as? ReminderTableViewCell
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let reminderVC = storyboard.instantiateViewController(identifier: "ReminderViewControllerID") as? ReminderViewController {
            reminderVC.modalPresentationStyle = .automatic
            reminderVC.plantController = plantController
            reminderVC.plant = plant
            reminderVC.reminder = reminderCell?.reminder
            reminderVC.reminderDelegate = self
            present(reminderVC, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // BUG: swiping on cell that was just completed uses correct index path but needs to reload tableview first
    // Right swipe actions (last completed date)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let reminder = reminders[indexPath.row]
        
        // Last Date
        let lastDatePanel = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            completion(true)
        }
        
        var lastCompletedString = NSLocalizedString("Last: ", comment: "last time completed") + "\n" + DateFormatter.shortTimeAndDateFormatter.string(from: reminder.lastDate ?? Date())
        if reminder.lastDate == nil {
            lastCompletedString = NSLocalizedString("Made: ", comment: "date created label") + "\n" +
                "\(DateFormatter.shortTimeAndDateFormatter.string(from: reminder.dateCreated!))"
        }
        
        lastDatePanel.title = lastCompletedString
        lastDatePanel.backgroundColor = UIColor.colorsArray[Int(reminder.colorIndex)]

        let config = UISwipeActionsConfiguration(actions: [lastDatePanel])
        config.performsFirstActionWithFullSwipe = false
                
        return config
    }
    
    // Left swipe actions (Silence, Delete)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let reminder = reminders[indexPath.row]
        
        // Delete
        let delete = UIContextualAction(style: .destructive, title: "") { (action, view, completion) in
            print("Deleted \(reminder.actionName!)")
            if let plant = self.plant {
                UIAlertController.makeReminderDeletionWarningAlert(reminder: reminder, plant: plant, indexPath: indexPath, vc: self)
            }
            completion(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
            
        // Silence
        let silence = UIContextualAction(style: .normal, title: "\(reminder.actionName!)") { (action, view, completion) in
            print("Silenced \(reminder.actionName!)")
            if let plant = self.plant {
                self.plantController?.toggleReminderNotification(plant: plant, reminder: reminder)
                self.resultsTableView.reloadRows(at: [indexPath], with: .right)
            }
            completion(true)
        }
        silence.image = reminder.isEnabled ? UIImage(systemName: "bell.slash.fill") : UIImage(systemName: "bell.fill")
        silence.backgroundColor = .systemIndigo
        
        let config = UISwipeActionsConfiguration(actions: [delete, silence])
        config.performsFirstActionWithFullSwipe = false
        
        return config
        }
}

// MARK: - NotepadDelegate

extension DetailViewController: NotepadDelegate {
    // receive the notepad we made in other screen and set ours to what we get back
    func didMakeNotepad(notepad: NotePad) {
        self.notePad = notepad
    }
    
    // same as above but this way we can update views with "new" plant
    func didMakeNotepadWithPlant(notepad: NotePad, plant: Plant) {
        self.notePad = notepad
        self.plant = plant
    }
}

// MARK: - SelectedResultDelegate

extension DetailViewController: SelectedResultDelegate {
    
    /// When user taps a cell in SearchVC, it passes back the PlantSearchResult and the image inside the cell's plantImageView
    func didSelectResult(searchResult: PlantSearchResult, image: UIImage?) {
        
        self.plantSearchResult = searchResult
        
        // if we DO want it to put common name selected into species field
        if UserDefaults.standard.bool(forKey: .resultFillsSpeciesTextfield) && searchResult.commonName != nil {
            speciesTextField.text = searchResult.commonName
        }
        
        // only replace the imageView.image if we passed back a searchResult that had an imageUrl and an image loaded
        if searchResult.imageUrl != nil && image != nil {
            self.imageView.image = image
        }
    }
}

// MARK: - AppearanceDelegate

extension DetailViewController: AppearanceDelegate {
    
    func didSelectAppearanceObjects(image: UIImage?) {
        imageView.image = image
    }
    
    func didSelectColorsAndIcons(appearanceOptions: AppearanceOptions) {
        self.appearanceOptions = appearanceOptions
        plantButton.backgroundColor = UIColor.colorsArray[Int(appearanceOptions.plantColorIndex)]
        waterPlantButton.backgroundColor = UIColor.colorsArray[Int(appearanceOptions.actionColorIndex)]
    }
}

// MARK: - ReminderDelegate

extension DetailViewController: ReminderDelegate {
    
    func didAddOrUpdateReminder() {
        resultsTableView.reloadData()
    }
}
