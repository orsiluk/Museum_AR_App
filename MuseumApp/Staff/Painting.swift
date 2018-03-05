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
    var photo: UIImage? //Optional
    var content: String?
    
    // Types
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let content = "content"
    }
    
    // Initializing
    init?(name: String, photo: UIImage?, content:String?){ // Because of ? it is a failable initializer
        // Initialization should fail if there's no name or rating is negative
        
        if name.isEmpty {
            return nil
        }
        
        //        guard (rating >= 0) && (rating <= 5) else {
        //            return nil
        //        }
        
        // Initialize poroperties
        self.name = name
        self.photo = photo
        self.content = content
    }
    
    // NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(content, forKey: PropertyKey.content)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        //required modifier means this initializer must be implemented on every subclass, if the subclass defines its own initializers. The convenience modifier means that this is a secondary initializer, and that it must call a designated initializer from the same class.
        
        // The name is not optional. If name string can't be decoded, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Painting object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Painting, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let content = aDecoder.decodeObject(forKey: PropertyKey.content) as? String
        
        self.init(name: name, photo: photo, content: content)
    }
    
    // We need a persistent path on the file system where data will be saved and loaded, so you know where to look for it.
    
    // Archive path
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("paintings")
}
