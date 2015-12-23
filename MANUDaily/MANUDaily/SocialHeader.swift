//
//  SocialHeader.swift
//  MANUDaily
//
//  Created by TUYENBQ on 12/5/15.
//  Copyright © 2015 TUYENBQ. All rights reserved.
//

import UIKit
enum SharingType{
   case FaceBook
   case Twitter
   case GooglePlus
}
class SocialHeader: UIView {
    var sharingWithType: ((type: SharingType) -> Void)?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    }

    @IBAction func facebookSharingButtonClicked(sender: AnyObject) {
        if let callback = self.sharingWithType {
            callback (type: SharingType.FaceBook)
        }
    }
    
    @IBAction func twitterSharingButtonClicked(sender: AnyObject) {
        if let callback = self.sharingWithType {
            callback (type: SharingType.Twitter)
        }
    }
    
    @IBAction func googlePlusSharingButtonClicked(sender: AnyObject) {
        if let callback = self.sharingWithType {
            callback (type: SharingType.GooglePlus)
        }
    }
    
    
}

extension SocialHeader{
    
}
