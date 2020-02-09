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
        signInButton.performFlare()
    }
    
    func changeToLogIn() {
        signInSegment.selectedSegmentIndex = 1
        loginType = .logIn
        print("Log In")
        signInButton.setTitle("Log In", for: .normal)
        signInButton.performFlare()
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        print("signInButtonTapped")
        
        if loginType == .signUp {
            signUp()
        }
        else {
            logIn()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.layer.cornerRadius = 5.0
        usernameTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no
        emailTextField.autocorrectionType = .no
        // Do any additional setup after loading the view.
    }
    
    private func signUp() {
        print("signUp() called")
         guard let userController = userController else {return}
         
         if let username = usernameTextField.text, let password = passwordTextField.text, let email = emailTextField.text, let phoneString = phoneTextField.text, !username.isEmpty, !password.isEmpty, !email.isEmpty, !phoneString.isEmpty {
            let phone = Int(phoneString) ?? 69
            let user = UserRepresentation(username: username, password: password, email: email, phone_number: phone, user_id: nil)
            
            globalUser = user
            print("Global user: \(globalUser!)")
            
            // Sign Up
            if loginType == .signUp {
                userController.signUp(userRep: user) { (error) in
                    if let error = error {
                        print("Error occured during sign up in signInButtonTapped() : \(error)")
                    } else {
                        DispatchQueue.main.async {
                            print("SIGN UP SUCCESS")
                            // Should try loging in still here
                            let alertController = UIAlertController(title: "Sign Up Successful!", message: "Please log in, \(user.username).", preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(alertAction)
                            self.present(alertController, animated: true, completion: nil)
                            self.changeToLogIn()
                        }
                    }
                }
            }
        }
        
        else {
            let alertController = UIAlertController(title: "Invalid Field", message: "Please fill in all fields", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func logIn() {
        print("logIn() called")
        guard let userController = userController else {return}
        
        // just check username and password since email and password aren't required and those fields aren't visible
        if let username = usernameTextField.text, let password = passwordTextField.text, let email = emailTextField.text, let phoneString = phoneTextField.text, !username.isEmpty, !password.isEmpty, !email.isEmpty, !phoneString.isEmpty {
            
            let phone = Int(phoneString) ?? 69
            let user = UserRepresentation(username: username, password: password, email: email, phone_number: phone, user_id: nil)
            
            userController.logIn(userRep: user) { (error) in
                if let error = error {
                    
                    DispatchQueue.main.async {
                        print("Error occured during log in in signInButtonTapped() LogInVC: \(error)")
                        let alertController = UIAlertController(title: "Log In Failed", message: "That user does not exist", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        print("LOG IN SUCCESS")
                        globalUser = user
                        if let globalUser = globalUser {
                            print("Global user: \(globalUser)")
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        else {
            let alertController = UIAlertController(title: "Invalid Field", message: "Please fill in all fields", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
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
