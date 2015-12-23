//
//  PhotoStreamViewController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 26/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit
import AVFoundation
import AlamofireImage
import Alamofire
import GradientCircularProgress

class PhotoStreamViewController: UICollectionViewController {
  
    var photos: NSMutableArray = NSMutableArray()
    var articleList: NSArray?
    let progress = GradientCircularProgress()
    var refreshControl: UIRefreshControl?
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let appAds = Ads()
    
    appAds.vc = self.navigationController?.visibleViewController
    
    
    appAds.initAdMobBanner() //loads AdMob banner
    
    let image = UIImage(named: GlobalConstants.ImageResources.manu_logo)
    navigationItem.titleView = UIImageView(image: image)
    
    // Set the PinterestLayout delegate
    if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
      layout.delegate = self
    }
    collectionView!.backgroundColor = UIColor.clearColor()
    collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
    
    if(Reachability.isConnectedToNetwork()){
    self.refreshControl = UIRefreshControl()
    self.refreshControl?.tintColor = GlobalConstants.BarButtonItemStype.TextColor
    self.refreshControl!.attributedTitle = NSAttributedString(string: GlobalConstants.messagePullToRefresh,attributes: [NSForegroundColorAttributeName: GlobalConstants.BarButtonItemStype.TextColor])
    self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    collectionView!.addSubview(refreshControl!)
    
    //load RSS first
    loadRSSFromServer(false)
    }else{
        let alert = UIAlertController(title: GlobalConstants.AlertSuccessfulView.Title, message: GlobalConstants.AlertSuccessfulView.NetworkMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: GlobalConstants.AlertSuccessfulView.ButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

    }
  }
    
    func refresh(sender:AnyObject)
    {
        // Code to refresh collection view
        loadRSSFromServer(true)
    }
    
    private func loadRSSFromServer(isPullToRefresh: Bool)->Void{
        if (!isPullToRefresh){
            progress.show(message: GlobalConstants.messageLoading,style:BlueDarkStyle())
        }
        
        let vivaObj  = DataProvider()
        vivaObj.delegate = self
        vivaObj.getAllArticles()
    }
    
}


extension PhotoStreamViewController: XMLParsingDoneForMUDelegate {
    func parsingDone(sender: DataProvider, muList: NSArray) {
        articleList = muList
        guard let arr = articleList else{
            return
        }
        for object in arr{
            let photo = Photo(dictionary: [GlobalConstants.Photo_Property.Caption:(object as? ManUAirticleObject)!.man_title!, GlobalConstants.Photo_Property.Comment:(object as? ManUAirticleObject)!.man_descripation!,GlobalConstants.Photo_Property.Photo:(object as? ManUAirticleObject)!.man_image!])
            photos.addObject(photo)
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.progress.dismiss()
            self.collectionView!.reloadData()
            self.refreshControl!.endRefreshing()
        }
        
    }
  // - MARK: collectionView Delegation
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let arr = articleList else{
        return 0;
    }
    
    return arr.count
  }
    
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GlobalConstants.collectionViewIdentifier, forIndexPath: indexPath) as! AnnotatedPhotoCell
    cell.photo = photos[indexPath.item] as? Photo
    return cell
  }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = articleList![indexPath.item] as? ManUAirticleObject
        
        let cellCelected = collectionView.cellForItemAtIndexPath(indexPath) as? AnnotatedPhotoCell
        cellCelected?.animationWhenItemSelected()
        if(Reachability.isConnectedToNetwork()){
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            // your function here
            let articleDetailVC = ArticleDetailViewController.instantiate()
            articleDetailVC.article_url = photo?.man_link
            self.navigationController!.pushViewController(articleDetailVC, animated: true)
        })
        }else{
            let alert = UIAlertController(title: GlobalConstants.AlertSuccessfulView.Title, message: GlobalConstants.AlertSuccessfulView.NetworkMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: GlobalConstants.AlertSuccessfulView.ButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
  
}

extension PhotoStreamViewController : PinterestLayoutDelegate {
  //Returns the photo height
  func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath , withWidth width:CGFloat) -> CGFloat {
        
    let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
    let rect  = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(700, 520), boundingRect)
    return rect.size.height
  }
  
  //Returns the annotation size based on the text
  func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
    let annotationPadding = CGFloat(4)
    let annotationHeaderHeight = CGFloat(17)
    
    let photo = photos[indexPath.item] as? Photo
    let font = UIFont(name: GlobalConstants.FontType.AvenirNext_Regular, size: 11)!
    let commentHeight = photo!.heightForComment(font, width: width)
    let height = annotationPadding + annotationHeaderHeight + commentHeight + annotationPadding
    return height
  }
}

