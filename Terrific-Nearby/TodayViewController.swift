//
//  TodayViewController.swift
//  Terrific-Nearby
//
//  Created by Christopher Truman on 9/24/14.
//
//

import UIKit
import NotificationCenter
import CoreLocation
import MapKit
import Fabric
import Crashlytics

class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    var manager = CLLocationManager()
    var places = [MKMapItem]()
    var defaults = NSUserDefaults(suiteName:"group.truman.Terrific")!
    var category = "eat"
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if (defaults.objectForKey("eat") == nil) {
            let defaultsDictionary = NSDictionary(contentsOfFile:(NSBundle.mainBundle().bundlePath as NSString).stringByAppendingPathComponent("Search_Params.plist"))!
            defaults.registerDefaults(defaultsDictionary as! [String : AnyObject])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Fabric.with([Crashlytics()])
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        if (defaults.objectForKey("nearby-places") != nil) {
            let newPlaces = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("nearby-places") as! NSData) as! [MKMapItem]
        
            if (places.count > 0){
                for view in self.view.subviews {
                    view.removeFromSuperview()
                }
                places = newPlaces
                updateWithPlaces(places, animated: false)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        coordinator.animateAlongsideTransition({ context in
//        }, completion:{ context in
//        })
    }
    
    @IBAction func segmentedValueChanged(sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            self.category = "eat"
            
        case 1:
            self.category = "shop"

        case 2:
            self.category = "watch"

        case 3:
            self.category = "play"
            
        default:
            self.category = "eat"
        }
        var currentLocation = manager.location
        var locationArray = NSArray(objects: NSNumber(double: currentLocation!.coordinate.latitude), NSNumber(double:currentLocation!.coordinate.longitude));
        
        var resultCount = self.view.traitCollection.verticalSizeClass == .Regular ? 6 : 4 as Int32
        SGNetworkManager.sharedManager().categorySearchWithCategory(self.category, locationArray: locationArray as [AnyObject], resultCount: resultCount, success: { places in
            //Fade out current state
            if (!self.isEqualToCachedPlaces(places as! [MKMapItem])){
                
                NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
                var placesData = NSKeyedArchiver.archivedDataWithRootObject(NSArray(array:places))
                self.defaults.setObject(placesData, forKey: "nearby-places")
                
                self.places = places as! [MKMapItem]
                //Add views with new state and fade in
                self.updateWithPlaces(self.places, animated: true)
            }
            }, failure: { error in
                self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 0)
        })

    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        if manager.location != nil {
            NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
            var currentLocation = manager.location
            var locationArray = NSArray(objects: NSNumber(double: currentLocation!.coordinate.latitude), NSNumber(double:currentLocation!.coordinate.longitude));
            
            var resultCount = self.view.traitCollection.verticalSizeClass == .Regular ? 6 : 4 as Int32
            SGNetworkManager.sharedManager().categorySearchWithCategory(self.category, locationArray: locationArray as [AnyObject], resultCount: resultCount, success: { places in
                //Fade out current state
                if (!self.isEqualToCachedPlaces(places as! [MKMapItem])){

                    NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
                    var placesData = NSKeyedArchiver.archivedDataWithRootObject(NSArray(array:places))
                    self.defaults.setObject(placesData, forKey: "nearby-places")
                    
                    self.places = places as! [MKMapItem]
                    //Add views with new state and fade in
                    self.updateWithPlaces(self.places, animated: true)
                    completionHandler(NCUpdateResult.NewData)
                }
                }, failure: { error in
                    self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 0)
                    completionHandler(NCUpdateResult.NoData)
            })
        } else {
            self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 0)
            completionHandler(NCUpdateResult.NoData)
        }

    }
    
    func updateWithPlaces(places: [MKMapItem], animated: Bool){
        var verticalSizeClass = self.view.traitCollection.verticalSizeClass
        var horizontalSizeClass = self.view.traitCollection.horizontalSizeClass
        
        var itemHeight = self.view.traitCollection.verticalSizeClass == .Regular ? 30.0 : 25.0 as CGFloat
        var fontSize = self.view.traitCollection.verticalSizeClass == .Regular ? 24.0 : 18.0 as CGFloat
        var padding = self.view.traitCollection.verticalSizeClass == .Regular ? 15.0 : 10.0 as CGFloat
        tableView.reloadData()
    }
    
    func openInMaps(sender: UIButton) {
        let mapItem = self.places[sender.tag]
        if (!mapItem.openInMapsWithLaunchOptions(nil)){
            //TODO: Handle tap when screen is locked
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus){
        if (status == .AuthorizedWhenInUse){
            NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
        }else if (status == .Denied || status == .Restricted){
            NCWidgetController.widgetController().setHasContent(false, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
        }
    }
    
    func isEqualToCachedPlaces(places: [MKMapItem]) -> (Bool){
        if (places.count != self.places.count){
            return false
        }
        for index in 0..<self.places.count{
            if (places[index] != self.places[index]){
                return false
            }
        }
        return true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var place = places[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as! UITableViewCell
        cell.textLabel?.text = place.name
        cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (!places[indexPath.row].openInMapsWithLaunchOptions(nil)){
            //TODO: Handle tap when screen is locked
        }
    }
}
