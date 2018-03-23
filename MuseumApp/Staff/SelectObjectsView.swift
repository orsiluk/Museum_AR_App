//
//  SelectObjectsView.swift
//  MuseumApp
//
//  Created by Orsolya Lukacs-Kisbandi on 18/03/2018.
//  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.
//

import UIKit
import SpriteKit

//class objCoord {
//    var upperEl = [Float]()
//    var lowerEl = [Float]()
//}

public struct objInfo{
    var posX: Int
    var posY: Int
    var width: CGFloat
    var height: CGFloat
    
    init(_ posX: Int, _ posY: Int, _ width: CGFloat, _ height: CGFloat) {
        self.posX = posX
        self.posY = posY
        self.width = width
        self.height = height
    }
}

protocol PropertyListReadable {
    func propertyListRepresentation() -> NSDictionary
    init?(propertyListRepresentation:NSDictionary?)
}

extension objInfo: PropertyListReadable {
    func propertyListRepresentation() -> NSDictionary {
        let representation:[String:AnyObject] = ["posX":self.posX as AnyObject, "posY":self.posY as AnyObject, "width":self.width as AnyObject, "height":self.height as AnyObject]
        return representation as NSDictionary
    }
    
    init?(propertyListRepresentation:NSDictionary?) {
        guard let values = propertyListRepresentation else {return nil}
        if  let xpos = values["posX"] as? Int,
            let ypos = values["posY"] as? Int,
            let withIm = values["width"] as? CGFloat,
            let heightIm = values["height"] as? CGFloat {
            self.posX = xpos
            self.posY = ypos
            self.width = withIm
            self.height = heightIm
        } else {
            return nil
        }
    }
}

//protocol SelectObjectsViewDelegate{
//    func sendObjectsArray(objects:[objInfo])
//}

class SelectObjectsView: UIViewController {
    
//    var delegate:SelectObjectsViewDelegate?
    
    @IBOutlet weak var displayPainting: UIImageView!
    public var theImagePassed: Painting?
    let overlay = UIView()
    var lastPoint = CGPoint()
    
    var touchPoint = CGPoint()
    var releasedPoint = CGPoint()
    var center = CGPoint()
    
//    var saveObjectsControler = StaffViewController?.self
    var myObjectArray = [objInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayPainting.image = theImagePassed?.photo
        
        // Do any additional setup after loading the view.
        overlay.layer.borderColor = UIColor.black.cgColor
        overlay.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        overlay.isHidden = true
        self.view.addSubview(overlay)
        
        //        displayPainting.image = self.DrawOnImage(startingImage: theImagePassed)
        print("Image was updated")
        
    }

    
    @IBAction func doneSelecting(_ sender: Any) {
        let addObjects = storyboard?.instantiateViewController(withIdentifier: "StaffViewController") as! StaffViewController
        theImagePassed?.objectArray = myObjectArray
        print("++ myObejct Array: \(String(describing:  theImagePassed?.objectArray))")
        addObjects.painting = theImagePassed
        navigationController?.pushViewController(addObjects, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Save original tap Point
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
            touchPoint = lastPoint
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Get the current known point and redraw
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            reDrawSelectionArea(fromPoint: lastPoint, toPoint: currentPoint)
        }
    }
    
    func reDrawSelectionArea(fromPoint: CGPoint, toPoint: CGPoint) {
        overlay.isHidden = false
        
        //Calculate rect from the original point and last known point
        let rect = CGRect(x: min(fromPoint.x, toPoint.x), y: min(fromPoint.y, toPoint.y), width: fabs(fromPoint.x - toPoint.x), height: fabs(fromPoint.y - toPoint.y))
        
        overlay.frame = rect
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        releasedPoint = touches.first!.location(in: view)
        
        let imageCenter = displayPainting.center
        
        if (releasedPoint.x > touchPoint.x) { //normal case
            center.x = touchPoint.x + (releasedPoint.x - touchPoint.x)/2
        } else {
            center.x = touchPoint.x - (touchPoint.x - releasedPoint.x)/2
        }
        
        if releasedPoint.y > touchPoint.y {
            center.y = touchPoint.y + (releasedPoint.y-touchPoint.y)/2
        } else {
            center.y = touchPoint.y - (touchPoint.y-releasedPoint.y)/2
        }
        
        var newObj = objInfo(0,0,0,0)
        newObj.posX = Int(-(imageCenter.x - center.x)/47)
        newObj.posY = Int((imageCenter.y - center.y)/47)
        newObj.width = CGFloat(abs(touchPoint.x - releasedPoint.x)/47)
        newObj.height = CGFloat(abs(touchPoint.y - releasedPoint.y)/47)
        myObjectArray.append(newObj)
//        reDrawSelectionArea(fromPoint: center, toPoint: CGPoint(x: center.x+5, y: center.y+5))
        
        //Make selected area not disappare
        
        print("Object info \(newObj.posX,newObj.posY,newObj.width, newObj.height)")
    }
}
