//
//  ArticleDetailViewController.swift
//  MANUDaily
//
//  Created by TUYENBQ on 11/26/15.
//  Copyright © 2015 TUYENBQ. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import GradientCircularProgress

class ArticleDetailViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,FHSTwitterEngineAccessTokenDelegate,MyPopupViewControllerDelegate,FBSDKSharingDelegate {
    var article_url: String?
    var articleDetail: ArticleDetailStruct?
    let progress = GradientCircularProgress()
    var sharing_type = 0
    @IBOutlet weak var myTableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let appAds = Ads()
        
        appAds.vc = self.navigationController?.visibleViewController
        
        appAds.initiAdBanner() //loads iAd banner
        
        appAds.initAdMobBanner() //loads AdMob banner
        // Do any additional setup after loading the view.
        let image = UIImage(named: GlobalConstants.ImageResources.manu_logo)
        navigationItem.titleView = UIImageView(image: image)
        
        progress.show(message: GlobalConstants.messageLoading,style:BlueDarkStyle())
        
        myTableview.delegate = self
        myTableview.dataSource = self
        myTableview.separatorStyle = .None
        let leftBarButtonItem = UIBarButtonItem(title: GlobalConstants.BarButtonItemStype.BackButtonString, style: UIBarButtonItemStyle.Done, target: self, action: "backButtonClicked:")
        leftBarButtonItem.tintColor = GlobalConstants.BarButtonItemStype.TextColor
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        DataProvider.parsingHTMLPage(article_url!) { (article: ArticleDetailStruct?, error: NSError?) -> Void in

            self.articleDetail = article
            self.myTableview.reloadData()
            self.progress.dismiss()
        }
        
        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey(GlobalConstants.TwitterAccount.Consumer_Key, andSecret: GlobalConstants.TwitterAccount.Consumer_Secret)
        FHSTwitterEngine.sharedEngine().delegate = self
        FHSTwitterEngine.sharedEngine().loadAccessToken()
    }
    
    func backButtonClicked(sender: UIBarButtonItem){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func socialButtonClicked(sender: UIBarButtonItem){
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static func instantiate() -> ArticleDetailViewController
    {
        return UIStoryboard(name: GlobalConstants.NibOfStoryboard.Main_Storyboard, bundle: nil).instantiateViewControllerWithIdentifier(GlobalConstants.NibOfStoryboard.ArticleDetailViewController) as! ArticleDetailViewController
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let nibView = NSBundle.mainBundle().loadNibNamed(GlobalConstants.socialFromNibNamed, owner: self, options: nil)[0] as? SocialHeader
        nibView?.sharingWithType = {
            (SharingType) -> Void in
            switch (SharingType){
            case .FaceBook:
                self.sharing_type = 1;
                let myPopupViewController:MyPopupViewController = MyPopupViewController(nibName:"MyPopupViewController", bundle: nil)
                myPopupViewController.delegate = self
                myPopupViewController.url = self.article_url
                self.presentpopupViewController(myPopupViewController, animationType: .TopBottom, completion: { () -> Void in
                    
                })
                break
                
            case .Twitter:
                self.sharing_type = 2;
                let myPopupViewController:MyPopupViewController = MyPopupViewController(nibName:"MyPopupViewController", bundle: nil)
                myPopupViewController.delegate = self
                myPopupViewController.url = self.article_url
                self.presentpopupViewController(myPopupViewController, animationType: .TopBottom, completion: { () -> Void in
                    
                })
                
                
                break
                
            case .GooglePlus:

                break
            }
        }
        return nibView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let font = UIFont(name: GlobalConstants.FontType.Gurmukhi_MN, size: 16)!
        let font1 = UIFont(name: GlobalConstants.FontType.Gurmukhi_MN_Bold, size: 18)!
        let insets = tableView.contentInset
        
        return DataProvider.heightArticleDetailCell(font,font1: font1, width: CGRectGetWidth(tableView.bounds) - (insets.left + insets.right) - 48, content: articleDetail)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(GlobalConstants.customCellIdentifier, forIndexPath: indexPath) as! ArticleDetailTableViewCell
        cell.selectionStyle = .None
        cell.articleDetailObj = articleDetail
        return cell
    }
    
    
    // MARK: - FHSTwitterEngine
    
    func tweetContentSharing(text: String){
        let error: NSError? =  FHSTwitterEngine.sharedEngine().postTweet("\(text)\n"+self.article_url!)
        guard error == nil else{
            return
        }
        
        let alert = UIAlertController(title: GlobalConstants.AlertSuccessfulView.Title, message: GlobalConstants.AlertSuccessfulView.SuccessMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: GlobalConstants.AlertSuccessfulView.ButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func storeAccessToken(accessToken: String!) {
        NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: "SavedAccessHTTPBody")
    }
    
    func loadAccessToken() -> String? {
        if let outputStr = NSUserDefaults.standardUserDefaults().objectForKey("SavedAccessHTTPBody") as? String{
            return outputStr
        }
        return nil
    }
    
    //MARK: MyPopupViewControllerProtocol
    func pressOK(sender: MyPopupViewController,text: String) {
        switch (sharing_type){
            case 1:
                let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
                content.contentURL = NSURL(string: article_url!)
                content.contentTitle = articleDetail?.title
                content.contentDescription = articleDetail?.summary
                FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
                self.dismissPopupViewController(.Fade)
            break
            
            case 2:
                print("press OK", terminator: "\n")
                if (!FHSTwitterEngine.sharedEngine().isAuthorized()){
                    let loginController = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler { (Bool success) -> Void in
                        print("success: \(success) \n", terminator: "")
                        self.tweetContentSharing(text)
                        self.dismissPopupViewController(.Fade)
                    }
                    
                    self.presentViewController(loginController, animated: true, completion: nil)
                }else{
                    self.tweetContentSharing(text)
                    self.dismissPopupViewController(.Fade)
                }
            break
            
        default:
            
            break
        }
        
        
    }
    func pressCancel(sender: MyPopupViewController) {
        
        print("press Cancel", terminator: "\n")
        self.dismissPopupViewController(.Fade)
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
