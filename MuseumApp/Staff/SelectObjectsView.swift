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
    let subOverlay = UIView()
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
        
        print(self.view.subviews)
        
        for object in myObjectArray{
            let addView = drawSelection(obj: object)
            
            print("Should display a lot of rectangles")
//            overlay.addSubview(addView)
//            overlayArray.append(addView)
        }
        
        // Do any additional setup after loading the view.
        overlay.layer.borderColor = UIColor.black.cgColor
        overlay.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        overlay.isHidden = false
        self.view.addSubview(overlay)
        
        subOverlay.layer.borderColor = UIColor.black.cgColor
        subOverlay.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        subOverlay.isHidden = true
        overlay.addSubview(subOverlay)
        
    }
    
    func drawSelection(obj: ObjInfo) -> UIView {
        
        let h = obj.height
        let w = obj.width
        let color:UIColor = UIColor.yellow
        
        let rect = CGRect(x: (w * 0.25),y: (h * 0.25),width: (w * 0.5),height: (h * 0.5))
        let bpath:UIBezierPath = UIBezierPath(rect: rect)
        
        color.set()
        bpath.stroke()
        let newOverlay = UIView()
        
        // Add the view to the view hierarchy so that it shows up on screen
        
        newOverlay.frame = rect
        self.view.addSubview(newOverlay)
        return newOverlay
//        let newOverlay = UIView()
//        overlayArray.append(newOverlay)
//        newOverlay.layer.borderColor = UIColor.black.cgColor
//        newOverlay.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
//        newOverlay.isHidden = false
//
//        let fromPointX = obj.posX - (obj.width/2)
//        let toPointX = obj.posX + (obj.width/2)
//        let fromPointY = obj.posY - (obj.height/2)
//        let toPointY = obj.posY + (obj.height/2)
//
//        let rect = CGRect(x: min(fromPointX, toPointX), y: min(fromPointY, toPointY), width: fabs(fromPointX - toPointX), height: fabs(fromPointY - toPointY))
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
        for view in overlay.subviews {
           view.removeFromSuperview()
        }
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
        subOverlay.isHidden = false
        
        //Calculate rect from the original point and last known point
        let rect = CGRect(x: min(fromPoint.x, toPoint.x), y: min(fromPoint.y, toPoint.y), width: fabs(fromPoint.x - toPoint.x), height: fabs(fromPoint.y - toPoint.y))
        
        subOverlay.frame = rect
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
        
        var newObj = ObjInfo(posX: 0,posY: 0,width: 0,height: 0)
        newObj.posX = CGFloat(-(imageCenter.x - center.x)/47)
        newObj.posY = CGFloat((imageCenter.y - center.y)/47)
        newObj.width = CGFloat(abs(touchPoint.x - releasedPoint.x)/47)
        newObj.height = CGFloat(abs(touchPoint.y - releasedPoint.y)/47)
        myObjectArray.append(newObj)
        let newView = drawSelection(obj: newObj)
        overlayArray.append(newView)
        overlay.addSubview(newView)
        
//        reDrawSelectionArea(fromPoint: center, toPoint: CGPoint(x: center.x+5, y: center.y+5))
        
        //Make selected area not disappare
        
//        print("Object info \(newObj.posX,newObj.posY,newObj.width, newObj.height)")
    }
}
