//
//  ViewController.swift
//  Travel Map Book
//
//  Created by Alper on 31.08.2018.
//  Copyright © 2018 Alper. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData



class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    
    
    var locationManager = CLLocationManager()
    var chosenLatitude: Double = 0
    var chosenLongitude: Double = 0
    
    
    var transmittedTitle = ""
    var transmittedSubtitle = ""
    var transmittedLatitude: Double = 0
    var transmittedLongitude: Double = 0
    
    var requestCLLocation = CLLocation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        commentTextField.delegate = self
        
        
        // MARK: MapView and Location Manager Attributes
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //MARK: Create Gesture Recognition
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(recognizer)
        
        if transmittedTitle  != "" {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: self.transmittedLatitude, longitude: self.transmittedLongitude)
            annotation.coordinate = coordinate
            annotation.title = self.transmittedTitle
            annotation.subtitle = self.transmittedSubtitle
            self.mapView.addAnnotation(annotation)
            
            self.nameTextField.text = self.transmittedTitle
            self.commentTextField.text = self.transmittedSubtitle
        }
        
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.04 , longitudeDelta: 0.04)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let chosenCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            self.chosenLatitude = chosenCoordinates.latitude
            self.chosenLongitude = chosenCoordinates.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = chosenCoordinates
            annotation.title = nameTextField.text
            annotation.subtitle = commentTextField.text
            mapView.addAnnotation(annotation)
            
            
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
         let reuseId = "myAnnoation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = UIColor.red
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if transmittedLatitude != 0 {
            if transmittedLongitude != 0 {
                self.requestCLLocation = CLLocation(latitude: transmittedLatitude, longitude: transmittedLongitude)
            }
        }
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placeMarks, error) in
            if let placemark = placeMarks {
                if placemark.count > 0{
                    let newPlaceMark = MKPlacemark(placemark: placemark[0])
                    let item = MKMapItem(placemark: newPlaceMark)
                    item.name = self.transmittedTitle
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
        }
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Locations", into: context)
        newLocation.setValue(nameTextField.text, forKey: "title")
        newLocation.setValue(commentTextField.text, forKey: "subtitle")
        newLocation.setValue(chosenLatitude, forKey: "latitude")
        newLocation.setValue(chosenLongitude, forKey: "longitude")
        do {
            try context.save()
            print("We managed to save data to CoreData")
        } catch {
            print("Error in saving data to Coredata")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newLocationCreated"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension MapVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
