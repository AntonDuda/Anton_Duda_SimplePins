//
//  MapViewController.swift
//  Anton_Duda_SimplePins
//
//  Created by Anton on 2/24/18.
//  Copyright © 2018 Anton Duda. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var annotationOldCoordinates: CLLocationCoordinate2D?
    
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: "MKAnnotationView")
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        if let pins = DBManager.shared.getPinsForCurrentUser() {
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
                mapView.addAnnotation(annotation)
            }
        }
        
        
        let doubleTap = UITapGestureRecognizer(target: self, action:#selector(self.addSomePin(_:)))
        doubleTap.numberOfTapsRequired = 3
        mapView.addGestureRecognizer(doubleTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        centerMapOnLocation(location: locValue)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        let manager = FBSDKLoginManager()
        manager.logOut()
       
        DBManager.shared.logOutCurrentUser()

        DispatchQueue.main.async {
            (UIApplication.shared.delegate as? AppDelegate)?.goToLogin()
        }
    }
    @objc private func addSomePin(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: mapView)
        let locCoordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoordinate
        
        self.mapView.addAnnotation(annotation)
        DBManager.shared.addPin(with: locCoordinate.longitude, and: locCoordinate.latitude)
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {return nil}
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "MKAnnotationView") as? MKPinAnnotationView
        view?.isDraggable = true
        view?.animatesDrop = true
        view?.annotation = annotation
        
        return view
    }
    
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationViewDragState,
                 fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            annotationOldCoordinates = view.annotation?.coordinate
        case .canceling:
            guard let aoc = annotationOldCoordinates else {return}
            annotationOldCoordinates = nil
            
            guard let annotation = view.annotation else {return}
            DBManager.shared.removePin(with: aoc.longitude, and: aoc.latitude)
            
            mapView.removeAnnotation(annotation)
        case .ending:
            guard let aoc = annotationOldCoordinates else {return}
            if let pin = DBManager.shared.getPint(with: aoc.longitude, and: aoc.latitude),
                let newAnnotation = view.annotation {
                pin.latitude = newAnnotation.coordinate.latitude
                pin.longitude = newAnnotation.coordinate.longitude
                DBManager.shared.saveContext()
            }
            annotationOldCoordinates = nil
        default:
            break
        }
    }
}

