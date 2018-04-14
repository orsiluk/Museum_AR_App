//
//  AdventureViewController.swift
//  MuseumApp
//
//  Created by Orsolya Lukacs-Kisbandi on 16/02/2018.
//  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.
//
import UIKit
import os.log
import AVFoundation

// When you press save, you want to go back, that's called an unwind segue, it means it takes you a step back
class StaffViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    // Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    //    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var addContent: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var paintingSize_x: UITextField!
//    @IBOutlet weak var gotObjArray: UIButton!
    
    /*
     This value is either passed by `StaffTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new painting.
     */
    public var painting: Painting?
    
    // http://iosrevisited.blogspot.co.uk/2017/11/voice-recorder-swift-4.html
    var recordButton = UIButton()
    var playButton = UIButton()
    var isRecording = false
    var audioRecorder: AVAudioRecorder?
    var player : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To set the AdventureViewController object as the delegate of its nameTextField property
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        nameTextField.tag = 0
        
        addContent.delegate = self
        addContent.tag = 1
        
        paintingSize_x.delegate = self
        paintingSize_x.tag = 2
        // Make sure AdventureViewController is notified when the user picks an image.
        
        // Set up views if editing an existing Painting.
        if let painting = painting {
            navigationItem.title = painting.name
            nameTextField.text   = painting.name
            photoImageView.image = painting.photo
            //            ratingControl.rating = painting.rating
            addContent.text = painting.content
            paintingSize_x.text = "\(String(describing: painting.phisical_size_x))"
        }
        
        // Enable the Save button only if the text field has a valid Painting name.
        updateSaveButtonState()
        
        view.backgroundColor = UIColor.black
//        recordButton.translatesAutoresizingMaskIntoConstraints = false
//        playButton.translatesAutoresizingMaskIntoConstraints = false
//        let anchorView = view.subviews[0].subviews[0].subviews[3]
//
//        view.addSubview(recordButton)
//        view.addSubview(playButton)
        
        // Asking user permission for accessing Microphone
        AVAudioSession.sharedInstance().requestRecordPermission () {
            [unowned self] allowed in
            if allowed {
                // Microphone allowed, do what you like!
                self.setUpUI()
            } else {
                fatalError("Recording acess denied")
                
            }
        }
        
        print("OBJECT COORDONATE ARRAY \(String(describing: painting?.objectArray))")
        
    }
    
    // Set up buttons and record audio
    
    // Adding play button and record button as subviews
    func setUpUI() {
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        let anchorView = view.subviews[0].subviews[0].subviews[4]

        view.addSubview(recordButton)
        view.addSubview(playButton)
        
        // Adding constraints to Record button
        recordButton.centerXAnchor.constraint(equalTo: anchorView.centerXAnchor, constant: 35).isActive = true
        recordButton.centerYAnchor.constraint(equalTo: anchorView.centerYAnchor, constant: 50).isActive = true
//        recordButton.trailingAnchor.constraint(equalTo: addContent.leadingAnchor).isActive = true
        
        let recordButtonHeightConstraint = recordButton.heightAnchor.constraint(equalToConstant: 60)
        recordButtonHeightConstraint.isActive = true
        recordButton.widthAnchor.constraint(equalTo: recordButton.heightAnchor, multiplier: 1.0).isActive = true
        recordButton.setImage(#imageLiteral(resourceName: "record"), for: .normal)
        recordButton.layer.cornerRadius = recordButtonHeightConstraint.constant/2
        recordButton.layer.borderColor = UIColor.white.cgColor
        recordButton.layer.borderWidth = 5.0
        recordButton.imageEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20)
        recordButton.addTarget(self, action: #selector(record(sender:)), for: .touchUpInside)
        
        // Adding constraints to Play button
        playButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor, multiplier: 1.0).isActive = true
        playButton.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -8).isActive = true
        playButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        playButton.addTarget(self, action: #selector(play(sender:)), for: .touchUpInside)
    }
    
    @objc func record(sender: UIButton) {
        if isRecording {
            finishRecording()
        }else {
            startRecording()
        }
    }
    
    @objc func play(sender: UIButton) {
        playSound()
    }
    
    func startRecording() {
        //1. create the session
        let session = AVAudioSession.sharedInstance()
        
        do {
            // 2. configure the session for recording and playback
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try session.setActive(true)
            // 3. set up a high-quality recording session
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            // 4. create the audio recording, and assign ourselves as the delegate
            audioRecorder = try AVAudioRecorder(url: getAudioFileUrl(), settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            //5. Changing record icon to stop icon
            isRecording = true
            recordButton.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
            recordButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
            playButton.isEnabled = false
        }
        catch _{
            os_log("Failed to record!")
        }
    }
    
    // Stop recording
    func finishRecording() {
        audioRecorder?.stop()
        isRecording = false
        recordButton.imageEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20)
        recordButton.setImage(#imageLiteral(resourceName: "record"), for: .normal)
    }
    
    // Path for saving/retreiving the audio file
    func getAudioFileUrl() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        // Here I want to pass in the painting's name, that way we can load it - Find a way to figure which painting it is - could save in a field the filename instead of anything else
        let name = nameTextField.text ?? ""
        let audioUrl = docsDirect.appendingPathComponent("\(name).m4a")
        return audioUrl
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            finishRecording()
        }else {
            // Recording interrupted by other reasons like call coming, reached time limit.
        }
        playButton.isEnabled = true
    }
    
    func playSound(){
        let url = getAudioFileUrl()
//        print("URL in STAFF: \(url)")
        do {
            // AVAudioPlayer setting up with the saved file URL
            let sound = try AVAudioPlayer(contentsOf: url)
            self.player = sound
            
            // Here conforming to AVAudioPlayerDelegate
            sound.delegate = self
            sound.prepareToPlay()
            sound.play()
            recordButton.isEnabled = false
        } catch {
            print("error loading file")
            // couldn't load file :(
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            
        }else {
            // Playing interrupted by other reasons like call coming, the sound has not finished playing.
        }
        recordButton.isEnabled = true
    }
    
    //UITextfieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        if textField.tag == 0 {
            navigationItem.title = textField.text
        }
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
        let isPresentingInAddPaintingMode = presentingViewController is UINavigationController
        
        if isPresentingInAddPaintingMode {
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
            os_log("The save button was not pressed.", log: OSLog.default, type: .debug)
            return
        }

        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let content = addContent.text ?? ""
        let gotSize = paintingSize_x.text ?? ""
        let pSize = Float(gotSize)
        let phisical_size_x = CGFloat(pSize!)
        //        let rating = ratingControl.rating
        let objectArray = painting?.objectArray
        print("<<<<< SHOULD HAVE OBJECTS \(String(describing: objectArray))")

        // Set the painting to be passed to StaffTableViewController after the unwind segue.
        painting = Painting(name: name, photo: photo!, content:content, phisical_size_x:phisical_size_x, objectArray:objectArray)
//
    }

    //This is where your implementation of UITextFieldDelegate methods comes in. You need to specify that the text field should resign its first-responder status when the user taps a button to end editing in the text field. You do this in the textFieldShouldReturn(_:) method, which gets called when the user taps Return (or in this case, Done) on the keyboard.
    
    // Actions:
    
    @IBAction func SelectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        //When a user taps the image view, they should be able to choose a photo from a collection of photos, or take one of their own. Fortunately, the UIImagePickerController class has this behavior built into it.
        
        // Hide the keyboard - This code ensures that if the user taps the image view while typing in the text field, the keyboard is dismissed properly.
        nameTextField.resignFirstResponder()
        //        addContent.resingFirstResponder()
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
    
    @IBAction func addObjectsToFind(_ sender: Any) {
        let toFindVC = storyboard?.instantiateViewController(withIdentifier: "SelectObjectsView") as! SelectObjectsView
        toFindVC.theImagePassed = painting
        navigationController?.pushViewController(toFindVC, animated: true)
    }
    
    // Private Methods:
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
        
        let size = paintingSize_x.text ?? ""
        saveButton.isEnabled = !size.isEmpty
    }
}
