//
//  UserViewController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var userController: UserController?
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let enteredUser = globalUser else {return}
        
        let userRep = UserRepresentation(username: enteredUser.username, password: enteredUser.password, email: enteredUser.email, phone_number: enteredUser.phone_number)
        
        userController?.updateUser(with: userRep, completion: { (error) in
            if let error = error {
                print("Error updating user in saveButtonTapped; \(error)")
            }
            else {
                DispatchQueue.main.async {
                    print("UPDATE SUCCESS")
                    self.updateViews()
                }
            }
        })
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //saveButton.isHidden = true
        saveButton.layer.cornerRadius = 5.0
        // Do any additional setup after loading the view.
        emailTextField.text = globalUser?.email
        phoneTextField.text = "\(globalUser?.phone_number ?? 911)"
        title = globalUser?.username
        passwordTextField.text = globalUser?.password
        
        
    }
    
    func updateViews() {
        print("updateviews")
        
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


