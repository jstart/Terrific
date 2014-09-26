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

class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate {
    var manager = CLLocationManager()
    var places = [MKMapItem]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.requestWhenInUseAuthorization()
//        NSNotificationCenter.defaultCenter().addObserver(NSNotificationCenter.defaultCenter(), selector: "userDefaultsDidChange:", name: NSUserDefaultsDidChangeNotification, object: nil)
        manager.delegate = self
        manager.startUpdatingLocation()
        NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        if ((NSUserDefaults(suiteName: "group.truman.Terrific").objectForKey("nearby-places")) != nil){
            var places = NSKeyedUnarchiver.unarchiveObjectWithData(NSUserDefaults(suiteName: "group.truman.Terrific").objectForKey("nearby-places") as NSData) as [MKMapItem]
        
            if (places.count > 0){
                for view in self.view.subviews {
                    view.removeFromSuperview()
                }
                self.places = places
                self.updateWithPlaces(places, animated: false)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        if manager.location != nil {
            NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
            var currentLocation = manager.location
            var locationArray = NSArray(objects: NSNumber(double: currentLocation.coordinate.latitude), NSNumber(double:currentLocation.coordinate.longitude));

            var resultCount : Int32
            resultCount = self.view.traitCollection.verticalSizeClass == .Regular ? 8 : 4
            
            SGNetworkManager.sharedManager().categorySearchWithCategory("eat", locationArray: locationArray, resultCount: resultCount, success: { places in
                //Fade out current state
                if (!self.isEqualToCachedPlaces(places as [MKMapItem])){
                    UIView.animateWithDuration(0.5, animations: {
                        for view in self.view.subviews {
                            for subview in view.subviews as [UIView] {
                                for subsubview in subview.subviews as [UIView] {
                                    subsubview.alpha = 0.0
                                }
                            }
                        }
                        }, completion:{ _ in
                            //Remove faded out views
                            for view in self.view.subviews {
                                view.removeFromSuperview()
                            }
                            NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
                            var placesData = NSKeyedArchiver.archivedDataWithRootObject(NSArray(array:places))
                            NSUserDefaults(suiteName: "group.truman.Terrific").setObject(placesData, forKey: "nearby-places")
                            
                            self.places = places as [MKMapItem]
                            //Add views with new state and fade in
                            self.updateWithPlaces(self.places, animated: true)
                    })
                }
                completionHandler(NCUpdateResult.NewData)
            }, failure: { error in
                    self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 0)
                    completionHandler(NCUpdateResult.NoData)
            })
        } else if(CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse){
            self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 0)
            NCWidgetController.widgetController().setHasContent(false, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
        }else{
            self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 0)
            completionHandler(NCUpdateResult.NoData)
        }
    }
    
    func updateWithPlaces(places: [MKMapItem], animated: Bool){
        var verticalSizeClass = self.view.traitCollection.verticalSizeClass
        var horizontalSizeClass = self.view.traitCollection.horizontalSizeClass
        self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 10.0 + (25.0 * CGFloat(places.count)))
        
        for index in 0..<places.count{
            var frame = CGRectMake(0, 0, self.view.frame.size.width, 20)
            var button = UIButton.buttonWithType(.System) as UIButton
            button.frame = frame
            button.titleLabel?.textAlignment = .Left
            button.contentHorizontalAlignment = .Left
            if (animated){
                button.alpha = 0.0
            }
            
            var visualEffectView = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
            visualEffectView.frame = button.bounds
            visualEffectView.frame.origin.x = 0
            visualEffectView.frame.origin.y = 10.0 + (25.0 * CGFloat(index))
            visualEffectView.contentView.addSubview(button)
            
            var place = places[index] as MKMapItem
            button.setTitle(place.name, forState: .Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            button.titleLabel!.font = UIFont.systemFontOfSize(18)
            button.tag = index
            button.addTarget(self, action: "openInMaps:", forControlEvents: .TouchUpInside)
            
            self.view.addSubview(visualEffectView)
        }
        if (animated){
            UIView.animateWithDuration(0.5, animations: {
                for view in self.view.subviews {
                    for subview in view.subviews as [UIView] {
                        for subsubview in subview.subviews as [UIView] {
                            subsubview.alpha = 1.0
                        }
                    }
                }
            })
        }
    }
    
    func openInMaps(sender: UIButton) {
        var mapItem = self.places[sender.tag]
        mapItem.openInMapsWithLaunchOptions(nil)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus){
        if (status == .AuthorizedWhenInUse){
            NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
        }else{
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
    
}
