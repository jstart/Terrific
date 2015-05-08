//
//  InterfaceController.swift
//  Terrific WatchKit Extension
//
//  Created by Christopher Truman on 5/7/15.
//
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet weak var map: WKInterfaceMap!
    var location = CLLocation()
    let locationManager = CLLocationManager()
    var category = "eat"
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        location = locations.first as! CLLocation
        
        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map.setRegion(region)
        self.map.removeAllAnnotations()
        searchCategory(self.category)
        locationManager.stopUpdatingLocation()
    }
    
    func searchCategory(category: String){
        self.category = category
        self.map.removeAllAnnotations()
        var locationArray = NSArray(objects: NSNumber(double: location.coordinate.latitude), NSNumber(double:location.coordinate.longitude));
        
        SGNetworkManager.sharedManager().categorySearchWithCategory(category, locationArray: locationArray as [AnyObject], resultCount: 4, success: { places in
            self.table.setNumberOfRows(places.count, withRowType: "Default")

            for (index, place) in enumerate(places as! [MKMapItem]) {
                let row = self.table.rowControllerAtIndex(index) as! SGPlaceRowController
                
                row.name.setText(place.name)
                row.subtitle.setText("")
                row.mapItem = place
                
                self.map.addAnnotation(place.placemark.location.coordinate, withPinColor: WKInterfaceMapPinColor.Red)
            }
            }, failure: { error in
        })
    }
    
    @IBAction func eat() {
        searchCategory("eat")
    }
    
    @IBAction func shop() {
        searchCategory("shop")
    }
    
    @IBAction func watch() {
        searchCategory("watch")
    }
    
    @IBAction func play() {
        searchCategory("play")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        locationManager.startUpdatingLocation()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        locationManager.stopUpdatingLocation()
    }

}
