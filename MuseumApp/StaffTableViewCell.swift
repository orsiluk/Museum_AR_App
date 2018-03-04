//
//  StaffTableViewCell.swift
//  MuseumApp
//
//  Created by Orsolya Lukacs-Kisbandi on 26/02/2018.
//  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.
//

import UIKit

class StaffTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    // Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
