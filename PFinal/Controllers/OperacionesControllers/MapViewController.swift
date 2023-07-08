//
//  MapViewController.swift
//  PFinal
//
//  Created by  Mac40 on 7/07/23.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var ubicacion = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            mapView.showsUserLocation = true
            ubicacion.startUpdatingLocation()
        }else{
            ubicacion.requestWhenInUseAuthorization()
        }
    }

}
