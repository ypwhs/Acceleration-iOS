//
//  MapViewControler.swift
//  Acceleration
//
//  Created by 杨培文 on 14/12/2.
//  Copyright (c) 2014年 杨培文. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class MapViewController: UIViewController,CLLocationManagerDelegate{
    @IBOutlet weak var map: MKMapView!
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate=self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locationManager.location
        let theSpan=MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let theRegion = MKCoordinateRegion(center: location!.coordinate, span: theSpan)
        map.setRegion(theRegion, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func back(_ sender: AnyObject) {
        dismiss(animated: true) { () -> Void in
        }
    }
}
