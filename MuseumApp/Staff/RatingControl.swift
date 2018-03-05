//
//  RatingControl.swift
//  MuseumApp
//
//  Created by Orsolya Lukacs-Kisbandi on 25/02/2018.
//  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    // You typically create a view in one of two ways: by programatically initializing the view, or by allowing the view to be loaded by the storyboard. There’s a corresponding initializer for each approach: init(frame:) for programatically initializing the view and init?(coder:) for loading the view from the storyboard.
    // You will need to implement both of these methods in your custom control. While designing the app, Interface Builder programatically instantiates the view when you add it to the canvas. At runtime, your app loads the view from the storyboard.
    
    //MARK: Properties
    private var ratingButtons = [UIButton]()
    
    //    To update the control, you need to reset the control’s buttons every time the attributes change in the storyboard.
    //    Here, you define property observers for the starSize and starCount properties. Specifically, the didSet property observer is called immediately after the property’s value is set. Your implementation then calls the setupButtons() method. This method adds new buttons using the updated size and count; however, the current implementation doesn’t get rid of the old buttons.
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0){
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Button Action
    @objc func ratingButtonTapped(button: UIButton) {
        print("Button pressed 👍")
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        
        // Calculate the rating of the selected button
        let selectedRating = index + 1
        
        if selectedRating == rating {
            // If the selected star represents the current rating, reset the rating to 0.
            rating = 0
        } else {
            // Otherwise set the rating to the selected star
            rating = selectedRating
        }
    }
    
    
    //MARK: Private Methods
    
    private func setupButtons(){
        
        // clear any existing buttons
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        // Load Button Images
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named:"emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named:"highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        
        // Here, you are using one of the UIButton class’s convenience initializers. This initializer calls init(frame:) and passes in a zero-sized rectangle.
        for index in 0..<starCount {
            let button = UIButton()
            // Set accesibility label
            button.accessibilityLabel  = "Set \(index + 1) star rating"
            
            button.setImage(emptyStar, for: .normal) // button's default image
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the new button to the rating button array
            ratingButtons.append(button)
        }
        
        updateButtonSelectionStates()
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            // If the index of a button is less than the rating, that button should be selected.
            button.isSelected = index < rating
            
            // Set the hint string for the currently selected star
            let hintString: String?
            if rating == index + 1 {
                hintString = "Tap to reset the rating to zero."
            } else {
                hintString = nil
            }
            
            // Calculate the value string
            let valueString: String
            switch (rating) {
            case 0:
                valueString = "No rating set."
            case 1:
                valueString = "1 star set."
            default:
                valueString = "\(rating) stars set."
            }
            
            // Assign the hint string and value string
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString
        }
    }
    
}

