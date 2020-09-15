//
//  MapViewController.swift
//  AnayaAustin-RollTheScones
//
//  Created by brandee m. on 7/9/20.
//  Copyright © 2020 anaya. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var location = ChoicesViewController.Location(lat: 0.0, lng: 0.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        checkLocationServices()
        
        let mapLocation = CLLocationCoordinate2DMake(location.lat, location.lng)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: mapLocation, span: span)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapLocation
        annotation.title = "your destination"
        annotation.title = "your destination (no peeking!)"
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            //actually do stuff
        case .authorizedWhenInUse:
            
            break
        case .denied:
            let controller = UIAlertController(title: "location permissions denied", message: "you'll have to turn on permissions", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "ok fine", style: .default, handler: nil))
            present(controller, animated: true, completion: nil)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            let controller = UIAlertController(title: "location services restricted", message: "location services are restricted", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            present(controller, animated: true, completion: nil)
        case .authorizedAlways:
            break
        default:
            break
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
        else {
            let controller = UIAlertController(title: "location services not enabled", message: "enable location services", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "ok fine", style: .default, handler: nil))
            present(controller, animated: true, completion: nil)
        }
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

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
}
