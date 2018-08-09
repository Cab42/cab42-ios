//
//  CreateGroupAnnotationView.swift
//  SearchDestination
//
//  Created by Andres Margendie on 31/07/2018.
//  Copyright © 2018 mc. All rights reserved.
//

import UIKit
import MapKit

private let mapPinImage = UIImage(named: "mapPin")!
private let mapAnimationTime = 0.200

class CreateGroupAnnotationView: MKAnnotationView {
    
    weak var groupDetailDelegate: CreateGroupViewDelegate?
    weak var customCalloutView: CreateGroupView?
    
    override var annotation: MKAnnotation? {
        willSet { customCalloutView?.removeFromSuperview() }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
        //self.calloutOffset = CGPoint(x: -5, y: 5)
        
        self.image = mapPinImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false // This is important: Don't show default callout.
        self.image = mapPinImage
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        print("aaaaa")

        if selected {
            print("bbbbbb")
            self.customCalloutView?.removeFromSuperview() // remove old custom callout (if any)
            
            if let newCustomCalloutView = loadCreateGroupView() {
                // fix location from top-left to its right place.
                newCustomCalloutView.frame.origin.x -= (newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0))
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                
                // set custom callout view
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                
                // animate presentation
                if animated {
                    self.customCalloutView!.alpha = 0.0
                    UIView.animate(withDuration: mapAnimationTime, animations: {
                        self.customCalloutView!.alpha = 1.0
                    })
                }
            }
        } else {
            print("ccccc")
           if customCalloutView != nil {
                if animated { // fade out animation, then remove it.
                    UIView.animate(withDuration: mapAnimationTime, animations: {
                        self.customCalloutView!.alpha = 0.0
                    }, completion: { (success) in
                        super.prepareForReuse()
                        self.customCalloutView!.removeFromSuperview()
                    })
                } else {
                    self.customCalloutView!.removeFromSuperview()
                }
            }
        }
    }
    
    
    func loadCreateGroupView() -> CreateGroupView? {
        if let views = Bundle.main.loadNibNamed("CreateGroupView", owner: self, options: nil) as? [CreateGroupView], views.count > 0 {
            let createGroupView = views.first!
            createGroupView.delegate = self.groupDetailDelegate
            
            if let groupAnnotation = annotation as? CreateGroupAnnotation {
                let group = groupAnnotation.group
                createGroupView.configureWithGroup(group: group, parent: self)
            }
            
            return createGroupView
        }
        return nil
    }
    
    func removeCalloutView(animated: Bool) {
        if customCalloutView != nil {
            if animated { // fade out animation, then remove it.
                UIView.animate(withDuration: mapAnimationTime, animations: {
                    self.customCalloutView!.alpha = 0.0
                }, completion: { (success) in
                    super.prepareForReuse()
                    self.customCalloutView!.removeFromSuperview()
                })
            } else {
                self.customCalloutView!.removeFromSuperview()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.customCalloutView?.removeFromSuperview()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if super passed hit test, return the result
        if let parentHitView = super.hitTest(point, with: event) {
            print("uno")
            return parentHitView
        }
        else { // test in our custom callout.
            if customCalloutView != nil {
                print("dos")
               return customCalloutView!.hitTest(convert(point, to: customCalloutView!), with: event)
            } else {
                print("tres")
                return nil
            }
        }
    }
    

    
    
}
