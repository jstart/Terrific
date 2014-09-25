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
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDefaultsDidChange:", name: NSUserDefaultsDidChangeNotification, object: nil)
        manager.delegate = self
        manager.startUpdatingLocation()
        NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ context in
            UIView.animateWithDuration(0.5, animations: {
                for view in self.view.subviews as [UIView] {
                    view.alpha = 0.0
                    for view in view.subviews as [UIView] {
                        view.alpha = 0.0
                    }
                }
            })
        }, completion:{ context in
        
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        var status = CLLocationManager.authorizationStatus
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        if manager.location != nil {
            NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
            var currentLocation = manager.location
            var locationArray = NSArray(objects: NSNumber(double: currentLocation.coordinate.latitude), NSNumber(double:currentLocation.coordinate.longitude));

            SGNetworkManager.sharedManager().categorySearchWithCategory("eat", locationArray: locationArray, resultCount: 6, success: { places in
                NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
                self.places = places as [MKMapItem]

                self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 15.0 + (25.0 * CGFloat(places.count)))
                for index in 0..<places.count{
                    var frame = CGRectMake(0, 0, self.view.frame.size.width-5, 20)
                    var button = UIButton.buttonWithType(.System) as UIButton
                    button.frame = frame
                    button.titleLabel?.textAlignment = .Left
                    button.contentHorizontalAlignment = .Left
                    
                    var visualEffectView = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
                    visualEffectView.frame = button.bounds
                    visualEffectView.frame.origin.x = 0
                    visualEffectView.frame.origin.y = 15.0 + (25.0 * CGFloat(index))
                    visualEffectView.contentView.addSubview(button)
                    
                    var place = places[index] as MKMapItem
                    button.setTitle(place.name, forState: .Normal)
                    button.setTitleColor(UIColor.purpleColor(), forState: .Normal)
                    button.tag = index
                    button.addTarget(self, action: "openInMaps:", forControlEvents: .TouchUpInside)
                    
                    self.view.addSubview(visualEffectView)
                }
                
                for visualEffectView in self.view.subviews as [UIView] {
                    UIView.animateWithDuration(0.75, delay: 0.0, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.5, options: nil, animations: {
                        visualEffectView.frame.origin.y -= 5
                        }, completion: nil)
                }
                
                completionHandler(NCUpdateResult.NewData)
            }, failure: { error in
                    self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 0)
                    NCWidgetController.widgetController().setHasContent(false, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
                    completionHandler(NCUpdateResult.NoData)
            })
        } else{
            self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 0)
            NCWidgetController.widgetController().setHasContent(false, forWidgetWithBundleIdentifier: "spotngo.Nearby-Places")
            completionHandler(NCUpdateResult.NoData)
        }
    }
    
    func openInMaps(sender: UIButton) {
        var mapItem = self.places[sender.tag]
        mapItem.openInMapsWithLaunchOptions(nil)
    }
    
}
