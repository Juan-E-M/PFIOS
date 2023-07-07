//
//  MapViewController.swift
//  PFinal
//
//  Created by Mac20 on 7/07/23.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    var contActualizaciones:Int = 0

    @IBOutlet weak var mapView: MKMapView!
    var ubicacion = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hello")
        ubicacion.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            mapView.showsUserLocation = true
            ubicacion.startUpdatingLocation()
            if let coord = self.ubicacion.location?.coordinate {
                let locations = [
                    CLLocationCoordinate2D(latitude: -15.842139, longitude: -70.021880), // Puno
                    CLLocationCoordinate2D(latitude: -15.639718, longitude: -71.605287), // Chivay
                    CLLocationCoordinate2D(latitude: -17.192488, longitude: -70.935717), // Moquegua
                    CLLocationCoordinate2D(latitude: -18.006566, longitude: -70.245653), // Tacna
                    CLLocationCoordinate2D(latitude: -16.621440, longitude: -72.711759)  // Camaná
                ]
                
                for location in locations {
                    let pin = MKPointAnnotation()
                    pin.coordinate = location
                    self.mapView.addAnnotation(pin)
                }
            }

        }else{
            ubicacion.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if contActualizaciones<1{
            let region = MKCoordinateRegion.init(center: ubicacion.location!.coordinate, latitudinalMeters: 400000, longitudinalMeters: 400000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }else{
            ubicacion.stopUpdatingLocation()
        }
    }
    
    @IBAction func centerTapped(_ sender: Any) {
        if let coord = ubicacion.location?.coordinate{
            let region = MKCoordinateRegion.init(center: ubicacion.location!.coordinate, latitudinalMeters: 400000, longitudinalMeters: 400000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }
    }
    
}
