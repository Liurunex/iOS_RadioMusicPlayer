//
//  UserCollectionView.swift
//  FinalProject
//
//  Created by Runex on 8/5/15.
//
//
import UIKit

class UserVolumeCell:  UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = true
        layer.cornerRadius = 5.0
    }
    
    
}
