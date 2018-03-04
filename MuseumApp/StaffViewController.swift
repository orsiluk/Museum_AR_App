//
//  AdventureViewController.swift
//  MuseumApp
//
//  Created by Orsolya Lukacs-Kisbandi on 16/02/2018.
//  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.
//

import UIKit
import os.log
// When you press save, you want to go back, that's called an unwind segue, it means it takes you a step back

class StaffViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
     This value is either passed by `StaffTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new painting.
     */
    public var painting: Painting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To set the AdventureViewController object as the delegate of its nameTextField property
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        // Make sure AdventureViewController is notified when the user picks an image.
        
        // Set up views if editing an existing Painting.
        if let painting = painting {
            navigationItem.title = painting.name
            nameTextField.text   = painting.name
            photoImageView.image = painting.photo
            ratingControl.rating = painting.rating
        }
        
        // Enable the Save button only if the text field has a valid Painting name.
        updateSaveButtonState()
        
        
    }
    //UITextfieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //disable the Save button when there’s no item name
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    //MARK: UIImagePickerControllerDelegate
    // This is how you make sure nothing bad happens if you press cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss if user cancelled
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // to do something with the image or images that a user selected from the picker. In your case, you’ll take the selected image and display it in your image view.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected image but got : \(info)")
        }
        
        // Display selected image at the photoview
        photoImageView.image = selectedImage
        
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    // Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }else {
            fatalError("The StaffViewController is not inside a navigation controller.")
        }
        
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender) // add a call to the superclass’s implementation
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        // Set the painting to be passed to StaffTableViewController after the unwind segue.
        painting = Painting(name: name, photo: photo, rating: rating)
        
    }
    
    
    
    //This is where your implementation of UITextFieldDelegate methods comes in. You need to specify that the text field should resign its first-responder status when the user taps a button to end editing in the text field. You do this in the textFieldShouldReturn(_:) method, which gets called when the user taps Return (or in this case, Done) on the keyboard.
    
    // Actions:
    
    @IBAction func SelectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        //When a user taps the image view, they should be able to choose a photo from a collection of photos, or take one of their own. Fortunately, the UIImagePickerController class has this behavior built into it.
        
        // Hide the keyboard - This code ensures that if the user taps the image view while typing in the text field, the keyboard is dismissed properly.
        nameTextField.resignFirstResponder()
        print("does know I tapped")
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        print("start picker")
        imagePickerController.sourceType = .photoLibrary // This line of code sets the image picker controller’s source, or the place where it gets its images. The .photoLibrary option uses the simulator’s camera roll.
        imagePickerController.delegate = self
        print("picked")
        present(imagePickerController, animated: true, completion: nil)
        print("should open window")
    }
    
    // Private Methods:
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}



