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
    
    @IBOutlet weak var displayPainting: UIImageView!
    public var theImagePassed: Painting?
    let overlay = UIView()
    var overlayArray = [UIView]()
    var lastPoint = CGPoint()
    
    var touchPoint = CGPoint()
    var releasedPoint = CGPoint()
    var center = CGPoint()
    var myObjectArray = [ObjInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if theImagePassed == nil {
            print("Something went wrong, painting not found!")
        }
        displayPainting.image = theImagePassed?.photo
        if theImagePassed?.objectArray != nil {
        myObjectArray = (theImagePassed?.objectArray)!
        }
        
        // Do any additional setup after loading the view. This is for the drawing.
        overlay.layer.borderColor = UIColor.black.cgColor
        overlay.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        overlay.isHidden = true
        self.view.addSubview(overlay)
    }
    
    func drawSelection(obj: ObjInfo) -> CGRect {
        
        let fromPointX = obj.posX - (obj.width/2)
        let toPointX = obj.posX + (obj.width/2)
        let fromPointY = obj.posY - (obj.height/2)
        let toPointY = obj.posY + (obj.height/2)

        let rect = CGRect(x: min(fromPointX, toPointX), y: min(fromPointY, toPointY), width: fabs(fromPointX - toPointX), height: fabs(fromPointY - toPointY))
        return rect
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
        
        var newObj = ObjInfo(posX: 0,posY: 0,width: 0,height: 0)
        
        let ratio  = displayPainting.frame.width / displayPainting.frame.height
        let physicalRef = (theImagePassed?.phisical_size_x)!/100
        let phisHeight = physicalRef/ratio
        
        newObj.posX = CGFloat(-(imageCenter.x - center.x) * physicalRef / displayPainting.frame.width)
        newObj.posY = CGFloat((imageCenter.y - center.y) * phisHeight / displayPainting.frame.height)
        newObj.width = CGFloat(abs(touchPoint.x - releasedPoint.x) * physicalRef / displayPainting.frame.width)
        
        newObj.height = CGFloat(abs(touchPoint.y - releasedPoint.y) * phisHeight / displayPainting.frame.height)
        myObjectArray.append(newObj)
    }
}
