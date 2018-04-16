//
//  SelectObjectsView.swift
//  MuseumApp
//
//  Created by Orsolya Lukacs-Kisbandi on 18/03/2018.
//  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.
//

import UIKit
import SpriteKit

class SelectObjectsView: UIViewController {
    
//    var delegate:SelectObjectsViewDelegate?
    
    @IBOutlet weak var displayPainting: UIImageView!
    public var theImagePassed: Painting?
    let overlay = UIView()
    var overlayArray = [UIView]()
    var lastPoint = CGPoint()
    
    var touchPoint = CGPoint()
    var releasedPoint = CGPoint()
    var center = CGPoint()
    
//    var saveObjectsControler = StaffViewController?.self
    var myObjectArray = [ObjInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayPainting.image = theImagePassed?.photo
        if theImagePassed?.objectArray != nil {
        myObjectArray = (theImagePassed?.objectArray)!
        }
        print(" <<<<<<<<<<<<<<<<<<<< \(displayPainting.frame.size)")
//        for object in myObjectArray{
//            var addView = drawSelection(obj: object)
//
//            print("Should display a lot of rectangles")
////            overlay.addSubview(addView)
////            overlayArray.append(addView)
//        }
        
        // Do any additional setup after loading the view. This is for the drawing.
        overlay.layer.borderColor = UIColor.black.cgColor
        overlay.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        overlay.isHidden = true
        self.view.addSubview(overlay)
        
        // This is for displaying
//        let subOverlay1 = UIView()
//        subOverlay1.layer.borderColor = UIColor.black.cgColor
//        subOverlay1.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
//        subOverlay1.isHidden = false
//        displayPainting.addSubview(subOverlay1)
//        subOverlay1.frame = drawSelection(obj: myObjectArray[0])
//        print(subOverlay1.frame)
//        
//        let subOverlay2 = UIView()
//        subOverlay2.layer.borderColor = UIColor.black.cgColor
//        subOverlay2.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
//        subOverlay2.isHidden = false
//        displayPainting.addSubview(subOverlay2)
//        subOverlay2.frame = drawSelection(obj: myObjectArray[1])
//        print(subOverlay2.frame)
        
        
    }
    
    func drawSelection(obj: ObjInfo) -> CGRect {
        
//        let h = obj.height
//        let w = obj.width
//        let color:UIColor = UIColor.yellow
//
//        let rect = CGRect(x: (w * 0.25),y: (h * 0.25),width: (w * 0.5),height: (h * 0.5))
//        let bpath:UIBezierPath = UIBezierPath(rect: rect)
//
//        color.set()
//        bpath.stroke()
//        let newOverlay = UIView()
//
//        // Add the view to the view hierarchy so that it shows up on screen
//
//        newOverlay.frame = rect
//        self.view.addSubview(newOverlay)
//        return newOverlay
        
        
//        let newOverlay = UIView()
//        overlayArray.append(newOverlay)
//        newOverlay.layer.borderColor = UIColor.black.cgColor
//        newOverlay.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
//        newOverlay.isHidden = false
//
        let fromPointX = obj.posX - (obj.width/2)
        let toPointX = obj.posX + (obj.width/2)
        let fromPointY = obj.posY - (obj.height/2)
        let toPointY = obj.posY + (obj.height/2)

        let rect = CGRect(x: min(fromPointX, toPointX), y: min(fromPointY, toPointY), width: fabs(fromPointX - toPointX), height: fabs(fromPointY - toPointY))
        return rect
//
//        newOverlay.frame = rect
//        return newOverlay
    }
    
    @IBAction func doneSelecting(_ sender: Any) {
        let addObjects = storyboard?.instantiateViewController(withIdentifier: "StaffViewController") as! StaffViewController
        theImagePassed?.objectArray = myObjectArray
        print("++ myObejct Array: \(String(describing:  theImagePassed?.objectArray))")
        addObjects.painting = theImagePassed
        navigationController?.pushViewController(addObjects, animated: true)
        
    }
    
    @IBAction func clearArray(_ sender: UIBarButtonItem) {
        myObjectArray.removeAll()
//        var i = true
//        for view in self.view.subviews {
//            if i {
//                i = false
//            } else {
//                view.removeFromSuperview()
//            }
//        }
//        overlay.layer.borderColor = UIColor.black.cgColor
//        overlay.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
//        overlay.isHidden = true
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
        
//        var newObj = ObjInfo(posX: 0,posY: 0,width: 0,height: 0)
//        newObj.posX = CGFloat(-(imageCenter.x - center.x)/47)
//        newObj.posY = CGFloat((imageCenter.y - center.y)/47)
//        newObj.width = CGFloat(abs(touchPoint.x - releasedPoint.x)/47)
//        newObj.height = CGFloat(abs(touchPoint.y - releasedPoint.y)/47)
//        myObjectArray.append(newObj)
        
        var newObj = ObjInfo(posX: 0,posY: 0,width: 0,height: 0)
        
        let ratio  = displayPainting.frame.width / displayPainting.frame.height
        let physicalRef = (theImagePassed?.phisical_size_x)!/100
        let phisHeight = physicalRef/ratio
        
        newObj.posX = CGFloat(-(imageCenter.x - center.x) * physicalRef / displayPainting.frame.width)
        newObj.posY = CGFloat((imageCenter.y - center.y) * phisHeight / displayPainting.frame.height)
        newObj.width = CGFloat(abs(touchPoint.x - releasedPoint.x) * physicalRef / displayPainting.frame.width)
        
        newObj.height = CGFloat(abs(touchPoint.y - releasedPoint.y) * phisHeight / displayPainting.frame.height)
        myObjectArray.append(newObj)
        
//        print(self.view1.frame.size)
        
//        let newView = drawSelection(obj: newObj)
//        overlayArray.append(newView)
//        overlay.addSubview(newView)
        
//        reDrawSelectionArea(fromPoint: center, toPoint: CGPoint(x: center.x+5, y: center.y+5))
        
        //Make selected area not disappare
        
//        print("Object info \(newObj.posX,newObj.posY,newObj.width, newObj.height)")
    }
}
