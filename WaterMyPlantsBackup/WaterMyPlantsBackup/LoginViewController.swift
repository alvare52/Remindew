//
//  LoginViewController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var signInSegment: UISegmentedControl!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            print("Sign Up")
            signInButton.setTitle("Sign Up", for: .normal)
            signInButton.backgroundColor = .systemGreen
            signInButton.performFlare()
        }
        else {
            print("Log In")
            signInButton.setTitle("Log In", for: .normal)
            signInButton.backgroundColor = .systemBlue
            signInButton.performFlare()
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        print("signInButtonTapped")
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

extension UIView {
  func performFlare() {
    func flare()   { transform = CGAffineTransform(scaleX: 1.1, y: 1.1) }
    func unflare() { transform = .identity }
    
    UIView.animate(withDuration: 0.2,
                   animations: { flare() },
                   completion: { _ in UIView.animate(withDuration: 0.2) { unflare() }})
  }
}
