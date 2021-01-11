//
//  MapViewController.swift
//  My Travel Book
//
//  Created by Serhat Küçük on 7.01.2021.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var placeNameText: UITextField!
    @IBOutlet weak var placeCommentText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIButton!

    var locationManager = CLLocationManager()
    var placeId = UUID()
    var placeName = String()
    var placeComment = String()
    var selectedLatitude = Double()
    var selectedLongitude = Double()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let coordinate = mapView.centerCoordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        
        if placeName != ""{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
                
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        let idString = placeId.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0{
                        for result in results as! [NSManagedObject]{
                            
                            if let name = result.value(forKey: "name") as? String{
                                placeName = name
                            }
                            
                            if let comment = result.value(forKey: "comment") as? String{
                                placeComment = comment
                            }
                            
                            if let latitude = result.value(forKey: "latitude") as? Double{
                                selectedLatitude = latitude
                            }
                            
                            if let longitude = result.value(forKey: "longitude") as? Double{
                                selectedLongitude = longitude
                                
                            }
                            
                            let annotation = MKPointAnnotation()
                            annotation.title = placeName
                            annotation.subtitle = placeComment
                            let coordinate = CLLocationCoordinate2D(latitude: selectedLatitude, longitude: selectedLongitude)
                            annotation.coordinate = coordinate
                            
                            mapView.addAnnotation(annotation)
                            
                            
                            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                            let region = MKCoordinateRegion(center: coordinate, span: span)
                            mapView.setRegion(region, animated: true)
                        }
                        saveButton.setTitle("Edit", for: .normal)
                      
                        
                    }

                    
                } catch  {
                    print("error")
                }
        
        }
        
        placeNameText.text = placeName
        placeCommentText.text = placeComment
        }
        
    

    

    
    @objc func selectLocation(gestureRecognizer: UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            let touchCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            selectedLatitude = touchCoordinates.latitude
            selectedLongitude = touchCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinates
            annotation.title = placeNameText.text
            annotation.subtitle = placeCommentText.text
            mapView.addAnnotation(annotation)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation is MKUserLocation {
                return nil
            }
            
            let reuseId = "myAnnotation"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView?.canShowCallout = true
                pinView?.tintColor = UIColor.black
                
                let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
                pinView?.rightCalloutAccessoryView = button
                
            } else {
                pinView?.annotation = annotation
            }
            
            
            
            return pinView
        }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if placeName != "" {
                
                let requestLocation = CLLocation(latitude: selectedLatitude, longitude: selectedLongitude)
                
                
                CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                    //closure
                    
                    if let placemark = placemarks {
                        if placemark.count > 0 {
                                          
                            let newPlacemark = MKPlacemark(placemark: placemark[0])
                            let item = MKMapItem(placemark: newPlacemark)
                            item.name = self.placeNameText.text
                            let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                            item.openInMaps(launchOptions: launchOptions)
                                          
                    }
                }
            }
                
                
            }
        
        
        
        
        }
        
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
       
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(placeNameText.text, forKey: "name")
        newPlace.setValue(placeCommentText.text, forKey: "comment")
        newPlace.setValue(selectedLatitude, forKey: "latitude")
        newPlace.setValue(selectedLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print ("success")
        } catch  {
            print("error")
        }
        if saveButton.titleLabel?.text == "Edit"{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = placeId.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == placeId{
                                context.delete(result)
                                
                                do {
                                    try context.save()
                                } catch  {
                                    print ("error")
                                }
                                break
                                
                            }
                            
                        }
                        
                    }
                }
            } catch  {
                print("error")
            }
            
        }
        
            
      
        NotificationCenter.default.post(name: NSNotification.Name("NewPlaceSaved"), object: nil)
        navigationController?.popViewController(animated: true)
    }
}
