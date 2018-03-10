////
////  resourceImages.swift
////  MuseumApp
////
////  Created by Orsolya Lukacs-Kisbandi on 09/03/2018.
////  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.
////
//
//import Foundation
//import ARKit
//import SceneKit
//import UIKit
//import os.log
//
//class resourceImages: NSObject, NSCoding{
//    
//    //Basic Properties of the data
//    
//    var name: String
//    var photo: CGImage
//    var physical_size_x: CGFloat
//    
//    // Types
//    struct PropertyKey {
//        static let name = "name"
//        static let photo = "photo"
//        static let physical_size_x = "physical_size_x"
//    }
//    
//    // Initializing
//    init?(name: String, photo: CGImage, physical_size_x:CGFloat){ // Because of ? it is a failable initializer
//        // Initialization should fail if there's no name
//        
//        if name.isEmpty {
//            return nil
//        }
//        
//        // Initialize poroperties
//        self.name = name
//        self.photo = photo
//        self.physical_size_x = physical_size_x
//    }
//    
//    required convenience init?(coder aDecoder: NSCoder) {
//        //required modifier means this initializer must be implemented on every subclass, if the subclass defines its own initializers. The convenience modifier means that this is a secondary initializer, and that it must call a designated initializer from the same class.
//        
//        // The name is not optional. If name string can't be decoded, the initializer should fail.
//        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
//            os_log("Unable to decode the name for a Painting object.", log: OSLog.default, type: .debug)
//            return nil
//        }
//
//        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as! CGImage
//        let physical_size_x = aDecoder.decodeObject(forKey: PropertyKey.physical_size_x) as! CGFloat
//        
//        self.init(name: name, photo: photo, physical_size_x: physical_size_x)
//    }
//}

