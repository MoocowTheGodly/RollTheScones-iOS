//
//  ChoicesViewController.swift
//  AnayaAustin-RollTheScones
//
//  Created by brandee m. on 7/8/20.
//  Copyright © 2020 anaya. All rights reserved.
//

import UIKit
import GooglePlaces
import FirebaseDatabase

class ChoicesViewController: UIViewController {
    
    @IBOutlet weak var foodTypeLabel: UILabel!
    @IBOutlet weak var standardsLabel: UILabel!
    @IBOutlet weak var lazyLabel: UILabel!
    @IBOutlet weak var leftNumberLabel: UILabel!
    @IBOutlet weak var rightNumberLabel: UILabel!
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var rollLabel: UILabel!
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var foodTypeButton: UIButton!
    
    //JSON formatting
    struct Root: Codable {
        var results: [SearchResult]
        var status: String
    }
    
    struct SearchResult: Codable {
        var id: String
        var icon: String
        var name: String
        var placeId: String
        var reference: String
        var types: [String]
        var formattedAddress: String
        var geometry: Geometry
        var openingHours: [String:Bool]?
    }

    struct Geometry: Codable  {
        var location: Location
    }

    struct Location: Codable  {
        var lat: Double
        var lng: Double
    }

    struct Photo: Codable {
        var height: Double
        var width: Double
        var photoReference: String
    }
    //JSON formatting
    
    let defaults = UserDefaults.standard
    let kThemeBackground = "themeBackground"
    let kThemeFont = "themeFont"
    let kAlwaysLoc = "password"
    let kIncludeVisited = "visited"
    
    var finalAddress = ""
    var finalID = ""
    
    var foodType = ""
    var foodTypes = ["American", "Chinese", "Indian", "Italian", "Mexican"]
    var standards = 1
    var distance = 15
    
    var currentUser = ""
    let kUserIdKey = "userID"
    let kPassword = "password"
    
    var childIdList:Array<String> = Array()
    var resultsIdList:Array<String> = Array()
    
    var resultsAddressList:Array<String> = Array()
    var locationList:Array<Location> = Array()
    var finalLocation = Location(lat: 0.0, lng: 0.0)
    
    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        foodTypeLabel.isHidden = true
        // Do any additional setup after loading the view.
        sliderView.minimumValue = 0
        sliderView.maximumValue = 30
        sliderView.value = 15
        
        currentUser = defaults.string(forKey: kUserIdKey)!
        currentUser = currentUser.replacingOccurrences(of: ".", with: ",")
    }
    
    @IBAction func foodTypeButtonPressed(_ sender: Any) {
        let controller = UIAlertController(title: "what are you feeling?", message: "select a type", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "american", style: .default, handler: { (selected) in
            self.foodType = "american"
            self.foodTypeLabel.text = "american"
            self.foodTypeLabel.isHidden = false
        }))
        controller.addAction(UIAlertAction(title: "chinese", style: .default, handler: { (selected) in
            self.foodType = "chinese"
            self.foodTypeLabel.text = "chinese"
            self.foodTypeLabel.isHidden = false
        }))
        controller.addAction(UIAlertAction(title: "indian", style: .default, handler: { (selected) in
            self.foodType = "indian"
            self.foodTypeLabel.text = "indian"
            self.foodTypeLabel.isHidden = false
        }))
        controller.addAction(UIAlertAction(title: "italian", style: .default, handler: { (selected) in
            self.foodType = "italian"
            self.foodTypeLabel.text = "italian"
            self.foodTypeLabel.isHidden = false
        }))
        controller.addAction(UIAlertAction(title: "mexican", style: .default, handler: { (selected) in
            self.foodType = "mexican"
            self.foodTypeLabel.text = "mexican"
            self.foodTypeLabel.isHidden = false
        }))
        controller.addAction(UIAlertAction(title: "Choose for me", style: .default, handler: { (selected) in
            self.foodType = self.foodTypes[Int(arc4random_uniform(5))]
            self.foodTypeLabel.text = self.foodType
        }))
        present(controller, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (defaults.object(forKey: kThemeBackground) != nil) {
            let backgroundColor = defaults.color(forKey: kThemeBackground)
            view.backgroundColor = backgroundColor
            self.segmentedControl.backgroundColor = UIColor.black
            self.segmentedControl.selectedSegmentTintColor = backgroundColor
        }
        
        if (defaults.object(forKey: kThemeFont) != nil) {
            let fontColor = defaults.color(forKey: kThemeFont)
            rollLabel.textColor = fontColor
            lazyLabel.textColor = fontColor
            milesLabel.textColor = fontColor
            standardsLabel.textColor = fontColor
            foodTypeLabel.textColor = fontColor
            leftNumberLabel.textColor = fontColor
            rightNumberLabel.textColor = fontColor
            self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: fontColor!], for: .normal)
            foodTypeButton.setTitleColor(fontColor, for: .normal)

        }

    }
    
    
    @IBAction func onScrollChanged(_ sender: Any) {
        milesLabel.isHidden = false

        milesLabel.text = "\(Int(sliderView.value)) miles"
    }
    
    
    @IBAction func onSegmentChosen(_ sender: Any) {
        standards = segmentedControl.selectedSegmentIndex + 1
    }
    
    //function to create the query string
    //minimum standard isn't included here, since it's always returned in a text search
    func createQueryString() -> String {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let query = "\(foodType)+dine+in+restaurants"
        //convert miles to meters
        let radius = Int(sliderView.value) * 1609
        
        var result = "https://maps.googleapis.com/maps/api/place/textsearch/json?"
        result += "query=\(query)"
        result += "&radius=\(radius)"
        result += "&opennow=true"
        result += "&type=restaurant"
        result += "&key=\(appDelegate.googleAPIKey)"

        return result
    }
    
    func textSearchWithQuery(input: String) {
        guard let url = URL(string: input) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let root = try decoder.decode(Root.self, from: data)
                    
                    //print(root.results.first?.formattedAddress as Any)
                    if (root.status == "ZERO_RESULTS") {
                        //we had zero results, do something
                        DispatchQueue.main.async {
                            self.finalAddress = "no results :(\neverything is either closed, or you're looking in a desert"
                        }
                        return
                    }
                        //set final address here
                    else {
                        //if we want to include places we've already been to
                        if (self.defaults.bool(forKey: self.kIncludeVisited)) {
                            DispatchQueue.main.async {
                                let random = Int(arc4random_uniform(UInt32(root.results.count)))
                                self.finalAddress = root.results[random].formattedAddress
                                self.finalID = root.results[random].id
                                self.finalLocation = root.results[random].geometry.location
                                self.performSegue(withIdentifier: "segueAddress", sender: nil)
                            }


                        }
                            //if we want to exclude restaurants the user has already visited
                        else {
                            let restIdRef = self.ref.child("users").child(self.currentUser).child("restaurantIDs")
                            restIdRef.observe(.value, with: { snapshot in
                                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                    for child in snapshots {
                                        self.childIdList.append(child.key)
                                    }
                                }
                                
                            })
                            if (self.childIdList.count == 0) {
                                DispatchQueue.main.async {
                                    let random = Int(arc4random_uniform(UInt32(root.results.count)))
                                    self.finalAddress = root.results[random].formattedAddress
                                    self.finalID = root.results[random].id
                                    self.finalLocation = root.results[random].geometry.location
                                    self.performSegue(withIdentifier: "segueAddress", sender: nil)
                                }
                            }
                            else {
                            //look at the ids in results, compare to the ids that the user has stored, then remove any that are in both lists from the results list
                                for i in 0...self.childIdList.count-1 {
                                    let idListString = self.childIdList[i]
                                    for j in 0...root.results.count-1 {
                                        let rootListString = root.results[j].id
                                        self.resultsIdList.append(rootListString)
                                        self.locationList.append(root.results[j].geometry.location)
                                        let rootAddressString = root.results[j].formattedAddress
                                        self.resultsAddressList.append(rootAddressString)
                                        //if the id is on the user list
                                        if (idListString == rootListString) {
                                            //remove from resultsIdList
                                            //removes all instances of the childIdString from the resultsIdList
                                            //also removes address from address list at the same index
                                            if let index = self.resultsIdList.firstIndex(of: idListString) {
                                                self.resultsIdList.remove(at: index)
                                                self.resultsAddressList.remove(at: index)
                                                self.locationList.remove(at: index)
                                            }
                                        }
                                    }
                                }
                                //find final address here
                                DispatchQueue.main.async {
                                    if (self.resultsIdList.count == 0) {
                                        self.finalAddress = "no results :(\nlooks like you've been everywhere!"
                                        return
                                    }
                                    let random = Int(arc4random_uniform(UInt32(self.resultsAddressList.count)))
                                    self.finalAddress = self.resultsAddressList[random]
                                    self.finalID = self.resultsIdList[random]
                                    self.finalLocation = self.locationList[random]
                                    self.performSegue(withIdentifier: "segueAddress", sender: nil)
                                }
                            }
                            
                        }
                    }
                } catch {
                    print(error)
                }
            
        }.resume()

    }

    @IBAction func rollButtonPressed(_ sender: Any) {
        //DEBUG
        print(createQueryString())
        //if missing an input field
        if (foodType.isEmpty) {
            let controller = UIAlertController(title: "missing food type!", message: "select a type", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "ok fine", style: .default, handler: nil))
            present(controller, animated: true, completion: nil)
            return
        }
        else {
            textSearchWithQuery(input: createQueryString())
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueAddress") {
            let nextVC = segue.destination as? AddressViewController
            
            nextVC?.address =  finalAddress
            nextVC?.id = finalID
            nextVC?.location = finalLocation
        }
    }
}
