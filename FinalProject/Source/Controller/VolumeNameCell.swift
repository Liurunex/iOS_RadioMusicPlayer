//
//  VolumeNameCell.swift
//  FinalProject
//
//  Created by Runex on 7/30/15.
//
//
import UIKit

protocol VolumeNameCellDelegate: class {
    func volumeNameCellDidSelectPlay(cell: VolumeNameCell)
    func volumeNameCellDidSelectDetails(cell: VolumeNameCell)
}

class VolumeNameCell:  UICollectionViewCell {
    @IBAction private func play(sender: AnyObject) {
        delegate?.volumeNameCellDidSelectPlay(self)
    }
    
    @IBAction private func details(sender: AnyObject) {
        delegate?.volumeNameCellDidSelectDetails(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = true
        layer.cornerRadius = 5.0
    }
    
    var channelID: Int = 0
    var urldata: String = ""
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var volumeImage: UIImageView!
    
    weak var delegate: VolumeNameCellDelegate?
}
