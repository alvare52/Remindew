//
//  UserViewController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var userViewController = UserController()
    var loginResponse: LoginResponse?
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        if let username = usernameTextField.text, let password = passwordTextField.text, let email = emailTextField.text, let phoneString = phoneTextField.text, !username.isEmpty, !password.isEmpty, !email.isEmpty, !phoneString.isEmpty {
            
           let phone = Int(phoneString) ?? 69
           let updatedUser = UserRepresentation(username: username, password: password, email: email, phone_number: phone, user_id: nil)
            
            userViewController.viewAllUsers(userRep: updatedUser, creds: universal) { (error) in
                if let error = error {
                    print("Error updating user in saveButtonTapped; \(error)")
                }
                else {
                    DispatchQueue.main.async {
                        print("VIEW ALL SUCCESS")
                        globalUser = updatedUser
                        print("Global user: \(updatedUser)")
                        //self.updateViews()
                    }
                }
            }
            
//           userViewController.updateUser(userRep: updatedUser, creds: universal) { (error) in
//               if let error = error {
//                   print("Error updating user in saveButtonTapped; \(error)")
//               }
//               else {
//                   DispatchQueue.main.async {
//                       print("UPDATE SUCCESS")
//                       globalUser = updatedUser
//                       print("Global user: \(updatedUser)")
//                       self.updateViews()
//                   }
//               }
//           }
            
        }
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //saveButton.isHidden = true
        saveButton.layer.cornerRadius = 5.0
        // Do any additional setup after loading the view.
        updateViews()
    }
    
    func updateViews() {
        print("updateviews")
        usernameTextField.text = globalUser?.username
        emailTextField.text = globalUser?.email
        phoneTextField.text = "\(globalUser?.phone_number ?? 911)"
        title = "\(globalUser?.username ?? "User")'s Profile"
        passwordTextField.text = globalUser?.password
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



