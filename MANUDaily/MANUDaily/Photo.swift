//
//  Photo.swift
//  RWDevCon
//
//  Created by Mic Pringle on 04/03/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class Photo {
    
  var caption: String
  var comment: String
  var image: String
  
  init(caption: String, comment: String, image: String) {
    self.caption = caption
    self.comment = comment
    self.image = image
  }
  
  convenience init(dictionary: NSDictionary) {
    let caption = dictionary[GlobalConstants.Photo_Property.Caption] as? String
    let comment = dictionary[GlobalConstants.Photo_Property.Comment] as? String
    let photo = dictionary[GlobalConstants.Photo_Property.Photo] as? String
    
    self.init(caption: caption!, comment: comment!, image: photo!)
  }
  
  func heightForComment(font: UIFont, width: CGFloat) -> CGFloat {
    let rect = NSString(string: comment).boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
    return ceil(rect.height)
  }
  
}
