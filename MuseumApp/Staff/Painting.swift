//  Painting.swift
//  MuseumApp
//
//  Created by Orsolya Lukacs-Kisbandi on 26/02/2018.
//  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.
//
// My very own data model, yeyy!
import UIKit
import os.log


class Painting: NSObject, NSCoding{

    //Basic Properties of the data
    
    var name: String
    var photo: UIImage
    var content: String? //Optional
    var phisical_size_x: CGFloat
    var objectArray : [objInfo]
    
    // Types
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let content = "content"
        static let phisical_size_x = "phisical_size_x"
        static let objectArray = "objectArray"
    }
    
    // Initializing
    init?(name: String, photo: UIImage, content:String?, phisical_size_x:CGFloat, objectArray:[objInfo]){ // Because of ? it is a failable initializer
        // Initialization should fail if there's no name
        
        if name.isEmpty {
            return nil
        }
        // Initialize poroperties
        self.name = name
        self.photo = photo
        self.content = content
        self.phisical_size_x = phisical_size_x
        self.objectArray = objectArray
    }
    
    // NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(content, forKey: PropertyKey.content)
        aCoder.encode(phisical_size_x, forKey: PropertyKey.phisical_size_x)
        aCoder.encode(objectArray, forKey:PropertyKey.objectArray)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        //required modifier means this initializer must be implemented on every subclass, if the subclass defines its own initializers. The convenience modifier means that this is a secondary initializer, and that it must call a designated initializer from the same class.
        
        // The name is not optional. If name string can't be decoded, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Painting object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Painting, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as! UIImage
        let content = aDecoder.decodeObject(forKey: PropertyKey.content) as? String
        let phisical_size_x = aDecoder.decodeObject(forKey: PropertyKey.phisical_size_x) as! CGFloat
        let objectArray = aDecoder.decodeObject(forKey: PropertyKey.objectArray) as? [objInfo]
        self.init(name: name, photo: photo, content: content, phisical_size_x: phisical_size_x, objectArray: objectArray!)
    }
    
    // We need a persistent path on the file system where data will be saved and loaded, so you know where to look for it.
    
    // Archive path
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("paintings")
}
