//
//  SettingsViewController.swift
//  AnayaAustin-RollTheScones
//
//  Created by brandee m. on 7/8/20.
//  Copyright © 2020 anaya. All rights reserved.
//

import UIKit
import Foundation

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var visitedLabel: UILabel!
    @IBOutlet weak var visitedSwitch: UISwitch!
    
    let themes = ["Dark", "Light", "Blue"]
    let themeBackgroundColors = [UIColor.black, UIColor.white, UIColor.blue]
    let themeFontColors = [UIColor.lightGray, UIColor.black, UIColor.white]
    
    let themeObject = Theme()
    
    
    let textCellIdentifier = "TextCell"


    let kThemeBackground = "themeBackground"
    let kThemeFont = "themeFont"
    let kIncludeVisited = "visited"
    let defaults = UserDefaults.standard
    
    var observer: NSKeyValueObservation? = nil
    var observer1: NSKeyValueObservation? = nil
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        visitedSwitch.thumbTintColor = UIColor.gray

        //observer to handle changing the theme as user selects a new theme
        observer = themeObject.observe(\Theme.backgroundColor, options: .new) { (theme, change) in
            self.view.backgroundColor = theme.backgroundColor
            self.tableView.backgroundColor = theme.backgroundColor
        }
        observer1 = themeObject.observe(\Theme.fontColor, options: .new) {
            (theme, change) in
            //change text colors
            self.themeLabel.textColor = theme.fontColor
            self.visitedLabel.textColor = theme.fontColor
            self.visitedSwitch.onTintColor = theme.fontColor
        }
        
        //if there are defaults for..
        if (defaults.object(forKey: kThemeBackground) != nil) {
            //load background colors
            let color = defaults.color(forKey: kThemeBackground)
            view.backgroundColor = color
            tableView.backgroundColor = color
            
            //load font colors
            let fontColor = defaults.color(forKey: kThemeFont)
            self.themeLabel.textColor = fontColor
            self.visitedLabel.textColor = fontColor
            
            //load other view colors
            self.visitedSwitch.onTintColor = fontColor
        }
        if (!defaults.bool(forKey: kIncludeVisited)) {
            let value = defaults.bool(forKey: kIncludeVisited)
            visitedSwitch.isOn = value
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = themes[row]
        cell.backgroundColor = themeBackgroundColors[row]
        cell.textLabel?.textColor = themeFontColors[row]
        //make selection look pretty
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.red
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    //function for user selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        //set vars
        themeObject.backgroundColor = themeBackgroundColors[row]
        themeObject.fontColor = themeFontColors[row]
        //set defaults
        self.defaults.set(themeBackgroundColors[row], forKey: self.kThemeBackground)
        self.defaults.set(themeFontColors[row], forKey: self.kThemeFont)

        
    }
    
    @IBAction func vistedSwitched(_ sender: Any) {
        defaults.set(visitedSwitch.isOn, forKey: kIncludeVisited)
    }
    
    
}




//used to store colors in user defaults
extension UserDefaults {
    
    func color(forKey key: String) -> UIColor? {
        guard let colorData = data(forKey: key) else { return nil }

        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } catch let error {
            print("color error \(error.localizedDescription)")
            return nil
        }

    }

    func set(_ value: UIColor?, forKey key: String) {
        guard let color = value else { return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            set(data, forKey: key)
        } catch let error {
            print("error color key data not saved \(error.localizedDescription)")
        }

    }

}
