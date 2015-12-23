//
//  AnnotatedPhotoCell.swift
//  RWDevCon
//
//  Created by Mic Pringle on 26/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit
import AlamofireImage
class AnnotatedPhotoCell: UICollectionViewCell {
  
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var imageViewHeightLayoutConstraint: NSLayoutConstraint!
  @IBOutlet private weak var captionLabel: UILabel!
  @IBOutlet private weak var commentLabel: UILabel!
    @IBOutlet weak var imageOverlay: UIImageView!
  
  var photo: Photo? {
    didSet {
      if let photo = photo {
        let URL = NSURL(string: photo.image)
        let placeholderImage = UIImage(named:GlobalConstants.ImageResources.no_image)!
        
        imageView.af_setImageWithURL(URL!, placeholderImage: placeholderImage)
        captionLabel.text = photo.caption
        commentLabel.text = photo.comment
      }
    }
  }
  
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    super.applyLayoutAttributes(layoutAttributes)
    if let attributes = layoutAttributes as? PinterestLayoutAttributes {
      imageViewHeightLayoutConstraint.constant = attributes.photoHeight
    }
  }
    //animation here
    func animationWhenItemSelected()->Void{
        
        UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseInOut, animations: {
            self.imageOverlay.alpha = 0.3;

            self.imageOverlay.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.0, 2.0)
            }, completion: { finished in
                self.imageOverlay.alpha = 0;

                self.imageOverlay.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001)
        })
    }
}
