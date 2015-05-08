//
//  SGPlaceRowController.swift
//  Terrific
//
//  Created by Christopher Truman on 5/7/15.
//
//

import WatchKit

class SGPlaceRowController: NSObject {
   
    @IBAction func button() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(mapItem)
        WKInterfaceController.openParentApplication(["mapItem":data ], reply: nil)
    }
    @IBOutlet weak var subtitle: WKInterfaceLabel!
    @IBOutlet weak var name: WKInterfaceLabel!
    
    var mapItem: MKMapItem!
}
