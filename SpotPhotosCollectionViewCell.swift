//
//  SpotPhotosCollectionViewCell.swift
//  
//
//  Created by J. Lozano on 11/20/18.
//

import UIKit

class SpotPhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photo: Photo! {
        didSet {
            photoImageView.image = photo.image
        }
    }

    
}
