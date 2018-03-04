/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Main view controller for the AR experience.
 */

import ARKit
import SceneKit
import UIKit
//import StatusViewControler

class AdventureViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.flatMap({ $0 as? StatusViewController }).first!
    }()
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        configureLighting()
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the AR experience
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.pause()
    }
    
    // Make things appare on tap --  Not working yet
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    // MARK: - Session management (Image detection setup)
    
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true
    
    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
    func resetTracking() {
        
        //        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources-1", bundle: nil) else {
        //            fatalError("Missing expected asset catalog resources.")
        //        }
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "Paintings", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
    }
    
    func addObject(color:String,x:Float,y:Float,z:Float) -> SCNNode{
        // Changes color and position of object based on input (later add other things like characters animations information etc)
        let myObect = SCNNode()
        myObect.geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.025)
        if color=="red"{
            myObect.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        }else if color=="blue"{
            myObect.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        } else{
            myObect.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        }
        
        myObect.position = SCNVector3(x,y,z)
        return myObect
    }
    
    func addPaperPlane(x: Float = 0, y: Float = 0, z: Float = 0) -> SCNNode{
        // if object found return it, else draw a red circle
        guard let paperPlaneScene = SCNScene(named: "paperPlane.scn"), let paperPlaneNode = paperPlaneScene.rootNode.childNode(withName: "paperPlane", recursively: true) else {
            print("Object not found!")
            return self.addObject(color: "red", x: x, y: y, z: z)}
        paperPlaneNode.position = SCNVector3(x, y, z)
//        sceneView.scene.rootNode.addChildNode(paperPlaneNode)
        paperPlaneNode.eulerAngles.x = -.pi / 2
        return paperPlaneNode
    }
    
    func addCar(x: Float = 0, y: Float = 0, z: Float = 0) -> SCNNode {
        // if object found return it, else draw a red circle
        guard let carScene = SCNScene(named: "car.dae") else {
            print("Object not found!")
            return self.addObject(color: "red", x: x, y: y, z: z) }
        let carNode = SCNNode()
        let carSceneChildNodes = carScene.rootNode.childNodes
        
        for childNode in carSceneChildNodes {
            carNode.addChildNode(childNode)
        }
        
        carNode.position = SCNVector3(x, y, z)
        carNode.scale = SCNVector3(0.2, 0.2, 0.2)
        carNode.eulerAngles.x = -.pi / 2
        return carNode
    }
    
    func addFly(x: Float = 0, y: Float = 0, z: Float = 0)-> SCNNode{
        // if object found return it, else draw a red circle
        guard let flyScene = SCNScene(named: "myFly.dae") else {
            print("Object not found!")
            return self.addObject(color: "red", x: x, y: y, z: z) }
        let flyNode = SCNNode()
        let flySceneChildNodes = flyScene.rootNode.childNodes
        
        for childNode in flySceneChildNodes {
            flyNode.addChildNode(childNode)
        }
        
        flyNode.position = SCNVector3(x, y, z)
        flyNode.scale = SCNVector3(0.02, 0.02, 0.02)
        flyNode.eulerAngles.x = -.pi / 2
        return flyNode
    }
    
    func configureLighting() {
        //COnfigure lighting for objects
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    
    
    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        // anchor contains inormation such as where the image was detected and the reference image we compared it to
        //Example: <ARImageAnchor: 0x1c015cd50 identifier="2A53DD07-4803-4725-8AC9-C5CF76C6EDEC" transform=<translation=(-0.188729 0.031420 -0.186292) rotation=(74.67° 16.62° 13.35°)> reference-image=<ARReferenceImage: 0x1c426f600 name="poppies" physical-size=(0.120, 0.090)>>
        
        print("--anchor -- \(anchor)")
        let referenceImage = imageAnchor.referenceImage
        print("****name = \(String(describing: referenceImage.name))")
        updateQueue.async {
            
            // Display a transparant plane over the detected painting. The physical size we add as a property to the asset catalog images is used here and it is important because the distance to the view point is calculated based on this.
            
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 0.15
            
            /*
             `SCNPlane` is vertically oriented in its local coordinate space, but
             `ARImageAnchor` assumes the image is horizontal in its local space, so
             rotate the plane to match.
             */
            planeNode.eulerAngles.x = -.pi / 2
            
            // This should flash for a while than stay there
            planeNode.runAction(self.imageHighlightAction)
            
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
            //Depending on which node I attache this to the reference point changes If I add it to planeNode whatever is applied to that node (animation etc. will happen to this obejct too)
            // node position is in the center of the detected image
            
            if (referenceImage.name == "poppies"){
//                node.addChildNode(self.addObject(color: "red", x: 0, y: 0.1, z: 0.2))
                print(" :) nodeposition: \(node.position)")
                // add object relative to the center of the image
                node.addChildNode(self.addCar(x: planeNode.position.x-Float(referenceImage.physicalSize.width)/2 - 0.1, y:planeNode.position.y, z:planeNode.position.z+Float(referenceImage.physicalSize.height)/2))
            }else if (referenceImage.name == "park"){
                // add object relative to the center of the image
                node.addChildNode(self.addFly(x: planeNode.position.x-Float(referenceImage.physicalSize.width)/2 - 0.1, y:planeNode.position.y, z:planeNode.position.z+Float(referenceImage.physicalSize.height)/2))
            }else if (referenceImage.name == "monet"){
                //                node.addChildNode(self.addObject(color: "green", x: 0, y: 0.2, z: 0.2))
                // add object relative to the center of the image
                node.addChildNode(self.addPaperPlane(x: planeNode.position.x-Float(referenceImage.physicalSize.width)/2 - 0.1, y:planeNode.position.y, z:planeNode.position.z+Float(referenceImage.physicalSize.height)/2))
            }else{
//                node.addChildNode(self.addPaperPlane(x:0, y:0.1, z:0.1))
                node.addChildNode(self.addObject(color: "green", x: planeNode.position.x-Float(referenceImage.physicalSize.width)/2 - 0.1, y:planeNode.position.y, z:planeNode.position.z+Float(referenceImage.physicalSize.height)/2))
            }
            
//             Tap gesture recognizer
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//            self.sceneView.addGestureRecognizer(tapGesture)
            
            print("--node-- \(node)")
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
