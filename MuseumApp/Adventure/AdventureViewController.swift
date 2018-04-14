//  AdventureViewConroller.swift
//  MuseumApp
//
//  Created by Orsolya Lukacs-Kisbandi on 16/02/2018.
//  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.

import ARKit
import SceneKit
import UIKit
import os.log
import AVFoundation


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
    var savedPaintings = [Painting]()
    var player : AVAudioPlayer?
    
    var objectsOnPainting = [String: [ObjInfo]]()
    
    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        //        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        //add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        self.sceneView.addGestureRecognizer(tapGesture)
        configureLighting()
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }
    
    //Method called when tap
    @objc func handleTap(rec: UITapGestureRecognizer){
        
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            
            // it crashes when the plane over the object is tapped.. why?
            
            if !hits.isEmpty{
                let tappedNode = hits.first?.node
//                print("---- Tapped Node: \(String(describing: tappedNode?.parent?.name))")
                
                if tappedNode!.parent?.name != nil {
                    print("WILL TRY to play this : \(String(describing: tappedNode!.parent?.name))")
                    self.playSound(name: String(describing: tappedNode!.parent!.name!))
                    
                }else if (tappedNode!.name != nil) {
                    print("WILL TRY to play this istead : \(String(describing: tappedNode!.name))")
                    self.playSound(name: String(describing: tappedNode!.name!))
                }else {
                    print("No sound attached");
                }
            }
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
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "Paintings", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        //print("----------------- \(referenceImages)")
        let configuration = ARWorldTrackingConfiguration() // Create configuration that detects six degrees of freedom (roll,pitch,yaw,x,y,z)
        configuration.detectionImages?.removeAll()
        savedPaintings.removeAll()
        savedPaintings = loadPaintings()!
        
        if sceneView.scene.rootNode.childNodes != [] {
            sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
                node.removeFromParentNode()
            }
        }
//        print("----- refrenceImages \(referenceImages)")
        if !(savedPaintings == []){
            var newRefIm = Set<ARReferenceImage>()
            // https://developer.apple.com/documentation/arkit/arreferenceimage/2942252-init
            for loaded in (savedPaintings) {
                let loadedPhoto = loaded.photo
                print("***** loadedPhoto: \(loaded.name)")

                let newRef = ARReferenceImage(loadedPhoto.cgImage!, orientation: CGImagePropertyOrientation.up, physicalWidth: loaded.phisical_size_x/100)
                // Set the elements of the dictionary - nameOfPainting->objectArray
                objectsOnPainting[loaded.name] = loaded.objectArray
                print("------ Object map element 1: \(String(describing: objectsOnPainting[loaded.name])) ----- Element 2 \(String(describing: loaded.objectArray))")
                // We have to conver physical_size_x into meters!
                newRef.name = loaded.name
                newRefIm.insert(newRef)
            }
            configuration.detectionImages = newRefIm
        }else {
            configuration.detectionImages = referenceImages // Specify what we want to detect
        }
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        statusViewController.scheduleMessage("Look around to find Paintings", inSeconds: 8, messageType: .contentPlacement)
    }
    
    
    
    private func loadPaintings() -> [Painting]?{
//        print("urlpath  :      \(Painting.ArchiveURL.path)")
        
        // TOFIX: If there is nothing saved on the device, it will crash.
        
        return (NSKeyedUnarchiver.unarchiveObject(withFile: Painting.ArchiveURL.path) as? [Painting])!
        // attempt to unarchive the object stored at the path Painting.ArchiveURL.path and downcast that object to an array of Painting objects
    }
 
    func getAudioFileUrl(name: String) -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        // Here I want to pass in the painting's name, that way we can load it - Find a way to figure which painting it is - could save in a field the filename instead of anything else
        let audioUrl = docsDirect.appendingPathComponent("\(name).m4a")
        print("Got audio URL")
        return audioUrl
    }
    
    func playSound(name: String){
        let url = getAudioFileUrl(name:name)
        print("Playing sound for painting \(name)")
        print("URL in ADVENTURE: \(url)")
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        do {
            // AVAudioPlayer setting up with the saved file URL
            let myAudio = try AVAudioPlayer(contentsOf: url)
            self.player = myAudio
            myAudio.delegate = self as? AVAudioPlayerDelegate
            myAudio.prepareToPlay()
            myAudio.play()
        } catch {
            print("error loading file")
            return
        }
    }
    
    // Display AR objects based on the detected paintings
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        // anchor contains inormation such as where the image was detected and the reference image we compared it to

        let referenceImage = imageAnchor.referenceImage
        print("---- Image with name = \(String(describing: referenceImage.name)) was found")
        updateQueue.async {
            
            let planeNode  = self.addPlaneOverPainting(detectedPainting: referenceImage, name: referenceImage.name!)
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
            //Depending on which node I attache this to the reference point changes If I add it to planeNode whatever is applied to that node (animation etc. will happen to this obejct too)
            // node position is in the center of the detected image
            let obj_pos_x = planeNode.position.x - Float(referenceImage.physicalSize.width)/2 - 0.1 // Put it on the left side 0.1 distance away from the painting edge
            let obj_pos_y = planeNode.position.y + 0.02 // Put it a bit more forward
            let obj_pos_z = planeNode.position.z + Float(referenceImage.physicalSize.height)/2 // put it on the same hight as the bottom of the painting
            //            let scale: Float = 0.25
            var newNode = SCNNode()
            
            if (referenceImage.name == "poppies"){
                print(" :) nodeposition where pimage was recognized: \(node.position)")
                // add object relative to the center of the image
                newNode = self.addObjectToScene(name: "tree", x: obj_pos_x+0.05, y: obj_pos_y, z: obj_pos_z, scale: 0.005)
            }else if (referenceImage.name == "park"){
                // add object relative to the center of the image
                newNode = self.addObjectToScene(name: "myFly", x: obj_pos_x, y: obj_pos_y, z: obj_pos_z, scale: 0.02)
            }else if (referenceImage.name == "princess"){
                
                // add object relative to the center of the image
                newNode = self.addObjectToScene(name: "paperPlane", x: obj_pos_x, y: obj_pos_y, z: obj_pos_z, scale: 1)
            }
            else{
                newNode = self.addObjectToScene(name: "default", x: obj_pos_x, y: obj_pos_y, z: obj_pos_z, scale: 1)
            }
            newNode.name = referenceImage.name
            node.addChildNode(newNode)

            self.foundPaintings[imageAnchor] = planeNode // add to the dictionary a pair of <ImageAnchor,SCNNode()> where SCNNode is my new plane that is over the painting
            //self.playSound(name: "Painting_\(String(describing: referenceImage.name))")
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
    
    func configureLighting() {
        //COnfigure lighting for objects
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    // Display a transparant plane over the detected painting. The physical size we add as a property to the asset catalog images is used here and it is important because the distance to the view point is calculated based on this.
    func addPlaneOverPainting(detectedPainting:ARReferenceImage, name: String) -> SCNNode{
        
        // To add a picture over instead we can do this:
        /* plane.materials = [SCNMaterial()]
         plane.materials[0].diffuse.contents = UIImage(named: imageName) */
        
        
//        let plane = SCNPlane(width: detectedPainting.physicalSize.width,
//                             height: detectedPainting.physicalSize.height)
        let planeNode = SCNNode()
//        planeNode.opacity = 0.05
        
        let objects = objectsOnPainting[name]!
        print(objects)
        for obj in objects {
            print("Addig object to \(obj.posX,obj.posY)")
            let miniPlane = SCNPlane(width: CGFloat(obj.width),
                                     height: CGFloat(obj.height))
            let objPlane = SCNNode(geometry: miniPlane)
            objPlane.position = SCNVector3(obj.posX,0,obj.posY)
            objPlane.opacity = 0.30
            objPlane.eulerAngles.x = -.pi / 2
            planeNode.addChildNode(objPlane)
        }
        
        
        /*
         `SCNPlane` is vertically oriented in its local coordinate space, but
         `ARImageAnchor` assumes the image is horizontal in its local space, so
         rotate the plane to match.
         */
//        planeNode.eulerAngles.x = -.pi / 2
        
        // This should flash for a while than stay there
//        planeNode.runAction(self.imageHighlightAction)
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
