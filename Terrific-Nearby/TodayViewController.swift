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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDefaultsDidChange:", name: NSUserDefaultsDidChangeNotification, object: nil)
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        manager.startUpdatingLocation()
        if manager.location != nil {
            var currentLocation = manager.location
            var locationArray = NSArray(objects: NSNumber(double: currentLocation.coordinate.latitude), NSNumber(double:currentLocation.coordinate.longitude));

            SGNetworkManager.sharedManager().categorySearchWithCategory("eat", locationArray: locationArray, resultCount: 6, success: { places in
                self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 10.0 + (25.0 * CGFloat(places.count)))
                for index in 0..<places.count{
                    var frame = CGRectMake(0, 0, self.view.frame.size.width-5, 20)
                    var label = UILabel(frame: frame)

                    var visualEffectView = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
                    visualEffectView.frame = label.bounds
                    visualEffectView.frame.origin.x = self.view.frame.size.width
                    visualEffectView.frame.origin.y = 10.0 + (25.0 * CGFloat(index))
                    visualEffectView.contentView.addSubview(label)
                    var place = places[index] as MKMapItem
                    label.text = place.name
                    label.textColor = UIColor.whiteColor()
                    label.alpha = 1.0
                    self.view.tintColor = UIColor.clearColor()
                    self.view.addSubview(visualEffectView)
                }
                
                for label in self.view.subviews as [UIView] {
                    UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: nil, animations: {
                            label.alpha = 1.0
                            label.frame.origin.x = 5
//                        for subview in label.subviews as [UIView] {
//                            UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: nil, animations: {
//                                subview.alpha = 1.0
//                                subview.frame.origin.x = 5
//                                }, completion: nil)
//                        }
                        }, completion: nil)
                }

                completionHandler(NCUpdateResult.NewData)
                }, failure: { error in
                    self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 0)
                    completionHandler(NCUpdateResult.NoData)
            });
        } else{
            self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 0)
            completionHandler(NCUpdateResult.NoData)
        }
    }
    
}
