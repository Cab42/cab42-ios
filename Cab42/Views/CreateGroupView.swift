//
//  CreateGroupView.swift
//  SearchDestination
//
//  Created by Andres Margendie on 31/07/2018.
//  Copyright © 2018 mc. All rights reserved.
//

protocol CreateGroupViewDelegate: class {
    func createGroup(passengers: Int, suitcases: Int)
}

import UIKit

class CreateGroupView: UIView{
    
    @IBOutlet weak var crearGroupBtn: UIButton!
    @IBOutlet weak var backgroundContentButton: UIButton!
    
    @IBOutlet weak var passengersLabel: UILabel!
    @IBOutlet weak var passengersStepper: UIStepper!
    
    var group: Group!
    weak var delegate: CreateGroupViewDelegate?
    var parentAnnotationView: CreateGroupAnnotationView!
    
    
    @IBOutlet weak var destinationLabel: UILabel!
    
    @IBAction func crearGroupBtnPressed(_ sender: Any) {
        self.parentAnnotationView?.removeCalloutView(animated: false)
        delegate?.createGroup(passengers: Int(passengersLabel.text!)!, suitcases: 0)
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        passengersLabel.text = Int(sender.value).description
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundContentButton.applyArrowDialogAppearanceWithOrientation(arrowOrientation: .down)
    }
    
    
    func configureWithGroup(group: Group, parent: CreateGroupAnnotationView) { // 5
        self.group = group
        self.parentAnnotationView = parent
        destinationLabel.text?.append("\n")
        destinationLabel.text?.append(group.destination)
        destinationLabel.text?.append("\n")
        destinationLabel.text?.append(group.locality)
    }
    
    // MARK: - Hit test. We need to override this to detect hits in our custom callout.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if let result = passengersStepper.hitTest(convert(point, to: passengersStepper), with: event) {
            return result
        }
        if let result = crearGroupBtn.hitTest(convert(point, to: crearGroupBtn), with: event) {
            return result
        }
        return backgroundContentButton.hitTest(convert(point, to: backgroundContentButton), with: event)
    }
}
