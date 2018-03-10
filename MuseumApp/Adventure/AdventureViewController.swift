//  AdventureViewConroller.swift
//  MuseumApp
//
//  Created by Orsolya Lukacs-Kisbandi on 16/02/2018.
//  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.

import ARKit
import SceneKit
import UIKit
import os.log

//import StatusViewControler

class AdventureViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    // The view controller -- displays the status and Restart experience UI.
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.flatMap({ $0 as? StatusViewController }).first!
    }()
    
    // A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    // Acess session
    var session: ARSession {
        return sceneView.session
    }
    
    // Dictionary of <ImageAnchor, Planeoverlay> that has all detected paintings in it
    var foundPaintings = [ARImageAnchor: SCNNode]()
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        configureLighting()
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from going dark to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the AR experience
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }
    
    // Image detection setup
    
    // Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true
    
    // Creates a new AR configuration to run on the `session`.
    
    func resetTracking() {
        self.foundPaintings.removeAll() // Removes all elements from the dictionary if scene is reset.
        guard var referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "Paintings", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        print("----------------- \(referenceImages)")
        let configuration = ARWorldTrackingConfiguration() // Create configuration that detects six degrees of freedom (roll,pitch,yaw,x,y,z)

//        print("Reference images \(referenceImages)")
//        print("Configuration images \(configuration)")

        
        let savedPaintings = loadPaintings()
//        var loadedRefImages = [ARReferenceImage]()
        // https://developer.apple.com/documentation/arkit/arreferenceimage/2942252-init
        for loaded in (savedPaintings)! {
            let loadedPhoto = loaded.photo
            let newRef = ARReferenceImage(loadedPhoto as! CGImage, orientation: CGImagePropertyOrientation.up, physicalWidth: loaded.phisical_size_x!)
            referenceImages.insert(newRef)
        }
            
        configuration.detectionImages = referenceImages // Specify what we want to detect
        
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        statusViewController.scheduleMessage("Look around to find Paintings", inSeconds: 8, messageType: .contentPlacement)
    }
    
    private func loadPaintings() -> [Painting]?{
        return NSKeyedUnarchiver.unarchiveObject(withFile: Painting.ArchiveURL.path) as? [Painting]
        // attempt to unarchive the object stored at the path Painting.ArchiveURL.path and downcast that object to an array of Painting objects
    }
    
//    func loadPhotosFromDevice() -> [CGImage]{
//        let fileManager = FileManager.default
//        var photos = [CGImage]()
////        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        do {
//            let fileURLs = try fileManager.contentsOfDirectory(at: Painting.DocumentsDirectory, includingPropertiesForKeys: nil)
//            // process files
//            print("............................. \(fileURLs)")
//            for thisFile in fileURLs {
//                print(thisFile.path)
//                let photo = NSKeyedUnarchiver.unarchiveObject(withFile: thisFile.path) as! CGImage
////                guard let name = aDecoder.decodeObject(forKey: Painting.PropertyKey.name) as? String else {
////                    os_log("Unable to decode the name for a Painting object.", log: OSLog.default, type: .debug)
////                    return photos
////                }
//
//                // Because photo is an optional property of Painting, just use conditional cast.
////                let photo = aDecoder.decodeObject(forKey: Painting.PropertyKey.photo) as! CGImage
//                photos.append(photo)
//            }
//
//
//        } catch {
//            print("Error while enumerating file: \(error.localizedDescription)")
//        }
//
//        // The name is not optional. If name string can't be decoded, the initializer should fail.
//
//
//        return photos
//    }
    
    
    
    // Display AR objects based on the detected paintings
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        // anchor contains inormation such as where the image was detected and the reference image we compared it to
        //Example: <ARImageAnchor: 0x1c015cd50 identifier="2A53DD07-4803-4725-8AC9-C5CF76C6EDEC" transform=<translation=(-0.188729 0.031420 -0.186292) rotation=(74.67° 16.62° 13.35°)> reference-image=<ARReferenceImage: 0x1c426f600 name="poppies" physical-size=(0.120, 0.090)>>
        let referenceImage = imageAnchor.referenceImage
        print("Image wit name = \(String(describing: referenceImage.name)) was found")
        updateQueue.async {
            let planeNode  = self.addPlaneOverPainting(detectedPainting: referenceImage)
            
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
            //Depending on which node I attache this to the reference point changes If I add it to planeNode whatever is applied to that node (animation etc. will happen to this obejct too)
            // node position is in the center of the detected image
            let obj_pos_x = planeNode.position.x - Float(referenceImage.physicalSize.width)/2 - 0.1
            let obj_pos_y = planeNode.position.y
            let obj_pos_z = planeNode.position.z + Float(referenceImage.physicalSize.height)/2
//            let scale: Float = 0.25
            var newNode = SCNNode()
            if (referenceImage.name == "poppies"){
                print(" :) nodeposition: \(node.position)")
                // add object relative to the center of the image
                newNode = self.addObjectToScene(name: "car", x: obj_pos_x, y: obj_pos_y, z: obj_pos_z, scale: 0.25)
                node.addChildNode(newNode)
            }else if (referenceImage.name == "park"){
                // add object relative to the center of the image
                newNode = self.addObjectToScene(name: "myFly", x: obj_pos_x, y: obj_pos_y, z: obj_pos_z, scale: 0.02)
                node.addChildNode(newNode)
            }else if (referenceImage.name == "princess"){
                
                // add object relative to the center of the image
                newNode = self.addObjectToScene(name: "paperPlane", x: obj_pos_x, y: obj_pos_y, z: obj_pos_z, scale: 1)
                node.addChildNode(newNode)
            }
            else{
                newNode = self.addObjectToScene(name: "default", x: obj_pos_x, y: obj_pos_y, z: obj_pos_z, scale: 1)
                node.addChildNode(newNode)
            }
            self.foundPaintings[imageAnchor] = planeNode // add to the dictionary a pair of <ImageAnchor,SCNNode()> where SCNNode is my new plane that is over the painting
            
        }
        
        // Update the paintings location -- I hope this will work
        
        func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor){
        
        }
        
        
        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
    }
    
    /*@IBAction func reCenter(_ sender: Any) {
        // I might not want this at all. If I use the detcted images as reference point I don't need to re-initialize
        self.sceneView.session.pause()
        //To remove all children :
//        self.sceneView.scene.rootNode.enumerateChildNodes{(node, _) in
//             node.removeFromParentNode()}
//        self.sceneView.session.run(configuration: ARConfiguration, options: self.resetTracking)
     
        self.sceneView.session.run(configuration, options: .resetTracking)
    }
    */
    
    func configureLighting() {
        //COnfigure lighting for objects
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    // Display a transparant plane over the detected painting. The physical size we add as a property to the asset catalog images is used here and it is important because the distance to the view point is calculated based on this.
    func addPlaneOverPainting(detectedPainting:ARReferenceImage) -> SCNNode{
        
        // To add a picture over instead we can do this:
        /* plane.materials = [SCNMaterial()]
        plane.materials[0].diffuse.contents = UIImage(named: imageName) */
        
        
        let plane = SCNPlane(width: detectedPainting.physicalSize.width,
                             height: detectedPainting.physicalSize.height)
        let planeNode = SCNNode(geometry: plane)
        print("Plane when I add it : \(plane)")
        planeNode.opacity = 0.15
        
        /*
         `SCNPlane` is vertically oriented in its local coordinate space, but
         `ARImageAnchor` assumes the image is horizontal in its local space, so
         rotate the plane to match.
         */
        planeNode.eulerAngles.x = -.pi / 2
        
        // This should flash for a while than stay there
        planeNode.runAction(self.imageHighlightAction)
        return planeNode
    }
    
    // Add AR object to the scene
    func addObjectToScene(name: String? = "default",x: Float = 0, y: Float = 0, z: Float = 0, scale: Float? = 1) -> SCNNode{ // Name and scale are optional
        let myObject = SCNNode() // Create Scenen node
        
        if name == "default"{
            //
            myObject.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.05)
            myObject.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            print("Input was \"default\" so generated a red sphere")
        }else {
            guard let objScene = SCNScene(named: "\(name ?? "default")" + ".dae") else { // Very insecure - FIX LATER
                print("Object not found!")
                return self.addObjectToScene(name:"default", x: x, y: y, z: z, scale:scale) }
            let objChildNodes = objScene.rootNode.childNodes
            
            for childNode in objChildNodes{
                myObject.addChildNode(childNode)
            }
        }
        
        myObject.position = SCNVector3(x, y, z)
        myObject.scale = SCNVector3(scale!, scale!, scale!)
        myObject.eulerAngles.x = -.pi / 2 // This might be a problem later - We rotate everything 90 degrees to the left
        print("Object with name \(String(describing: name)) was added")
        return myObject
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            // put these back in if want to make the white plane disappear
            //            .fadeOut(duration: 0.5),
            //            .removeFromParentNode()
            ])
    }
}
