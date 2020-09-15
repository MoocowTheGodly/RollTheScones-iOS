//
//  ViewController.swift
//  AnayaAustin-RollTheScones
//
//  Created by austin a. on 6/25/20.
//  Copyright © 2020 anaya. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var rememberLabel: UILabel!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sconesLabel: UILabel!
    
    @IBOutlet weak var switchView: UISwitch!
    let defaults = UserDefaults.standard
    let kThemeBackground = "themeBackground"
    let kThemeFont = "themeFont"
    let kAlwaysLoc = "alwaysLoc"
    let kIncludeVisited = "visited"
    let kUserIdKey = "userID"
    let kPassword = "password"
    let kRemember = "rememberMe"
    //if false, login
    //if true, sign up
    var selection = false
    var username = ""
    var password = ""
    var confirmPassword = ""

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        confirmLabel.isHidden = true
        confirmTextField.isHidden = true
        switchView.thumbTintColor = UIColor.gray
        
        //signing out by default
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
 
        Auth.auth().addStateDidChangeListener() {
            auth, user in
            if (user != nil) {
                self.statusLabel.text = "Logged in successfully."
                //save login for next time, also need to pass between views
                self.defaults.set(self.username, forKey: self.kUserIdKey)
                self.defaults.set(self.password, forKey: self.kPassword)
                self.performSegue(withIdentifier: "segueChoices", sender: nil)
            }
        }
        let mapViewController = MapViewController()
        mapViewController.checkLocationServices()
    }
        
    @IBAction func signButtonPressed(_ sender: Any) {
        //if we're logging in
        if (!selection) {
            if (userTextField.text?.isEmpty == true || passwordTextField.text?.isEmpty == true) {
                //not a valid login, send alert and do nothing
                let alert = UIAlertController(title: "One or more fields missing", message: "Please enter something for both fields.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            else {
                username = userTextField.text!
                password = passwordTextField.text!
                //login
                Auth.auth().signIn(withEmail: username, password: password) {
                 user, error in
                     if let error = error, user == nil {
                         let alert = UIAlertController(title: "Sign in failed", message: error.localizedDescription, preferredStyle: .alert)
                         alert.addAction(UIAlertAction(title: "OK", style: .default))
                         self.present(alert, animated: true, completion: nil)
                     }
                 }
            }
        }
        //if we're signing up
        else {
            if (userTextField.text?.isEmpty == true || passwordTextField.text?.isEmpty == true || confirmTextField.text?.isEmpty == true) {
                //not a valid login, send alert and do nothing
                let alert = UIAlertController(title: "One or more fields missing", message: "Please enter something for all fields.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            else {
                username = userTextField.text!
                password = passwordTextField.text!
                confirmPassword = confirmTextField.text!
                //if confirm password doesn't match password
                if (password != confirmPassword) {
                    let alert = UIAlertController(title: "Password does not match confirmed password.", message: "Please make sure you confirm your password.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    //create user
                    Auth.auth().createUser(withEmail: username, password: password) {
                        user, error in
                        if let error = error, user == nil {
                            let alert = UIAlertController(title: "Sign up failed", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        self.statusLabel.text = "Signed up successfully."
                    }
                }
            }
        }
    }
    
    @IBAction func selectionChanged(_ sender: Any) {
        //if we're signing in
        if (segmentedControl.selectedSegmentIndex == 0) {
            selection = false
            confirmLabel.isHidden = true
            confirmTextField.isHidden = true
            signButton.setTitle("Sign In", for: .normal)
        }
        //if we're signing up
        else if (segmentedControl.selectedSegmentIndex == 1) {
            selection = true
            confirmLabel.isHidden = false
            confirmTextField.isHidden = false
            signButton.setTitle("Sign Up", for: .normal)
        }
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        defaults.set(switchView.isOn, forKey: kRemember)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (defaults.object(forKey: kThemeBackground) != nil) {
            //load background colors
            let color = defaults.color(forKey: kThemeBackground)
            view.backgroundColor = color
            
            //load font colors
            let fontColor = defaults.color(forKey: kThemeFont)
            self.userLabel.textColor = fontColor
            self.passwordLabel.textColor = fontColor
            self.confirmLabel.textColor = fontColor
            self.signButton.setTitleColor(fontColor, for: .normal)
            self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: fontColor!], for: .normal)
            self.rememberLabel.textColor = fontColor
            self.sconesLabel.textColor = fontColor
            self.statusLabel.textColor = fontColor
            //load other view colors
            self.switchView.tintColor = fontColor
            self.switchView.onTintColor = fontColor
            
            self.userTextField.backgroundColor = UIColor.gray
            self.confirmTextField.backgroundColor = UIColor.gray
            self.passwordTextField.backgroundColor = UIColor.gray
            
            self.segmentedControl.backgroundColor = UIColor.black
            self.segmentedControl.selectedSegmentTintColor = color
        }
        if (defaults.object(forKey: kRemember) != nil) {
            switchView.isOn = defaults.bool(forKey: kRemember)
            if (defaults.object(forKey: kUserIdKey) != nil && defaults.bool(forKey: kRemember)) {
                userTextField.text = defaults.string(forKey: kUserIdKey)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueChoices") {
            segue.destination.navigationItem.setHidesBackButton(true, animated: false)
            //let nextVC = segue.destination as? ChoicesViewController
            //nextVC?.kUserKey = username
        }
        else if (segue.identifier == "segueSettings") {
            
        }
    }
}
