//
//  SelectObjectsView.swift
//  MuseumApp
//
//  Created by Orsolya Lukacs-Kisbandi on 18/03/2018.
//  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.
//

import UIKit


class SelectObjectsView: UIViewController {
    
    
    @IBOutlet weak var displayPainting: UIImageView!
    public var theImagePassed = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayPainting.image = theImagePassed
    }
}
