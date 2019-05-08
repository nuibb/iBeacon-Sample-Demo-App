/*
 * Copyright (c) 2017 Razeware LLC
 */

import UIKit

class IconCell: UICollectionViewCell {
    
    @IBOutlet weak var imgIcon: UIImageView!
    
    var icon: Icons? {
        didSet {
            guard let icon = icon else { return }
            imgIcon.image = icon.image()
        }
    }
    
}
