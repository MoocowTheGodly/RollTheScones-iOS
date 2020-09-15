//
//  AddressViewController.swift
//  AnayaAustin-RollTheScones
//
//  Created by brandee m. on 7/9/20.
//  Copyright © 2020 anaya. All rights reserved.
//

import UIKit
import FirebaseDatabase


class AddressViewController: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var otherAddressLabel: UILabel!
    
    var address = "address loading"
    var id = ""
    var location = ChoicesViewController.Location(lat: 0.0, lng: 0.0)
    
    let ref = Database.database().reference()
    let addressList = Array(String())
    
    let defaults = UserDefaults.standard
    let kThemeBackground = "themeBackground"
    let kThemeFont = "themeFont"
    let kUserIdKey = "userID"
    let kPassword = "password"
    
    var currentUser = ""
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = address
        currentUser = defaults.string(forKey: kUserIdKey)!
        currentUser = currentUser.replacingOccurrences(of: ".", with: ",")
        //print(address)
    }
    
    @IBAction func saveAddressButtonPressed(_ sender: Any) {
        let restIdRef = ref.child("users").child(currentUser).child("restaurantIDs").child(id)
        restIdRef.setValue(id)
        
    }
    
    
    @IBAction func navigateButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "segueMap", sender: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (defaults.object(forKey: kThemeBackground) != nil) {
            let backgroundColor = defaults.color(forKey: kThemeBackground)
            view.backgroundColor = backgroundColor
            
        }
        
        if (defaults.object(forKey: kThemeFont) != nil) {
            let fontColor = defaults.color(forKey: kThemeFont)
            whereLabel.textColor = fontColor
            addressLabel.textColor = fontColor
            otherAddressLabel.textColor = fontColor
            saveButton.setTitleColor(fontColor, for: .normal)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueMap") {
            let nextVC = segue.destination as? MapViewController
            nextVC?.location = location
        }
    }

}
