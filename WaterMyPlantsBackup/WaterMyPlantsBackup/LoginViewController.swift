//
//  LoginViewController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

enum LoginType {
    case signUp
    case logIn
}

// bad
var globalUser: UserRepresentation?

class LoginViewController: UIViewController {
    
    var loginType = LoginType.signUp
    var userController: UserController?

    @IBOutlet weak var signInSegment: UISegmentedControl!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            changeToSignUp()
        }
        else {
            changeToLogIn()
        }
    }
    
    func changeToSignUp() {
        signInSegment.selectedSegmentIndex = 0
        loginType = .signUp
        print("Sign Up")
        signInButton.setTitle("Sign Up", for: .normal)
        //signInButton.backgroundColor = .systemGreen
        signInButton.performFlare()
        emailTextField.isHidden = false
        phoneTextField.isHidden = false
    }
    
    func changeToLogIn() {
        signInSegment.selectedSegmentIndex = 1
        loginType = .logIn
        print("Log In")
        signInButton.setTitle("Log In", for: .normal)
        //signInButton.backgroundColor = .systemBlue
        signInButton.performFlare()
        emailTextField.isHidden = false // change later to true
        phoneTextField.isHidden = false // change later to true
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        print("signInButtonTapped")
        
        guard let userController = userController else {return}
        
        if let username = usernameTextField.text, let password = passwordTextField.text, let email = emailTextField.text, let phoneString = phoneTextField.text, !username.isEmpty, !password.isEmpty, !email.isEmpty, !phoneString.isEmpty {
            
            let phone = Int(phoneString) ?? 69
            let user = UserRepresentation(username: username, password: password, email: email, phone_number: phone, user_id: nil)
            
            globalUser = user
            
            // Sign Up
            if loginType == .signUp {
                userController.signUp(userRep: user) { (error) in
                    if let error = error {
                        print("Error occured during sign up in signInButtonTapped() : \(error)")
                    } else {
                        DispatchQueue.main.async {
                            print("SIGN UP SUCCESS")
                            // Should try loging in still here
                            self.changeToLogIn()
                        }
                    }
                }
            }
            
            // Log In
            else {
                print("TRYING TO LOG IN")
                userController.logIn(userRep: user) { (error) in
                    if let error = error {
                        print("Error occured during log in in signInButtonTapped(): \(error)")
                    } else {
                        DispatchQueue.main.async {
                            print("LOG IN SUCCESS")
                        }
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.layer.cornerRadius = 5.0
        // Do any additional setup after loading the view.
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

// Animation
extension UIView {
  func performFlare() {
    func flare()   { transform = CGAffineTransform(scaleX: 1.1, y: 1.1) }
    func unflare() { transform = .identity }
    
    UIView.animate(withDuration: 0.3,
                   animations: { flare() },
                   completion: { _ in UIView.animate(withDuration: 0.2) { unflare() }})
  }
}
