//
//  PinterestLayout.swift
//  Pinterest
//
//  Created by ernesto on 01/06/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit
protocol PinterestLayoutDelegate {
  //Method to ask the delegate for the height of the image
  func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath , withWidth:CGFloat) -> CGFloat
  //Method to ask the delegate for the height of the annotation text
  func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
  
}

class PinterestLayoutAttributes:UICollectionViewLayoutAttributes {
  
  //Custom attribute
  var photoHeight: CGFloat = 0.0
  
  //Override copyWithZone to conform to NSCopying protocol
  override func copyWithZone(zone: NSZone) -> AnyObject {
    let copy = super.copyWithZone(zone) as! PinterestLayoutAttributes
    copy.photoHeight = photoHeight
    return copy
  }
  
  //Override isEqual
  override func isEqual(object: AnyObject?) -> Bool {
    if let attributtes = object as? PinterestLayoutAttributes {
      if( attributtes.photoHeight == photoHeight  ) {
        return super.isEqual(object)
      }
    }
    return false
  }
}


class PinterestLayout: UICollectionViewLayout {
  //Pinterest Layout Delegate
  var delegate:PinterestLayoutDelegate!
  
  //Configurable properties
  var numberOfColumns = 2
  var cellPadding: CGFloat = 6.0
  
  //Array to keep a cache of attributes.
  private var cache = [PinterestLayoutAttributes]()
  
  //Content height and size
  private var contentHeight:CGFloat  = 0.0
  private var contentWidth: CGFloat {
    let insets = collectionView!.contentInset
    return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
  }
  
  override class func layoutAttributesClass() -> AnyClass {
    return PinterestLayoutAttributes.self
  }
  
  override func prepareLayout() {
    //Only calculate once
    if cache.isEmpty {
      
      // Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
      let columnWidth = contentWidth / CGFloat(numberOfColumns)
      var xOffset = [CGFloat]()
      for column in 0 ..< numberOfColumns {
        xOffset.append(CGFloat(column) * columnWidth )
      }
      var column = 0
      var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)
      
      // Iterates through the list of items in the first section
      for item in 0 ..< collectionView!.numberOfItemsInSection(0) {
        
        let indexPath = NSIndexPath(forItem: item, inSection: 0)
        
        // Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
        let width = columnWidth - cellPadding*2
        let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath , withWidth:width)
        let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
        let height = cellPadding +  photoHeight + annotationHeight + cellPadding
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
        
        // Creates an UICollectionViewLayoutItem with the frame and add it to the cache
        let attributes = PinterestLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.photoHeight = photoHeight
        attributes.frame = insetFrame
        cache.append(attributes)
        
        // Updates the collection view content height
        contentHeight = max(contentHeight, CGRectGetMaxY(frame))
        yOffset[column] = yOffset[column] + height
        
        column = column >= (numberOfColumns - 1) ? 0 : ++column
      }
    }
  }
  
  override func collectionViewContentSize() -> CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    // Loop through the cache and look for items in the rect
    for attributes  in cache {
      if CGRectIntersectsRect(attributes.frame, rect ) {
        layoutAttributes.append(attributes)
      }
    }
    return layoutAttributes
  }
}


