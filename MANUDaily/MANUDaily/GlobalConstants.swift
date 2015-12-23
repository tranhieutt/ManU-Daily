//
//  GlobalConstants.swift
//  MANUDaily
//
//  Created by TUYENBQ on 11/19/15.
//  Copyright © 2015 TUYENBQ. All rights reserved.
//

import Foundation
import UIKit
struct GlobalConstants {
    static let rssURLString = "http://www.manutd.com/en/Feeds/NewsAndFeaturesRSS.aspx"
    static let collectionViewIdentifier = "AnnotatedPhotoCell"
    static let messageLoading = "Loading..."
    static let messagePullToRefresh = "Release to update..."
    static let navigationBarBackgroundColor = UIColor(red:0.88, green:0.04, blue:0.04, alpha:1)
    static let customCellIdentifier = "articleCellIdentifier"
    static let socialFromNibNamed = "SocialHeader"
    
    struct ElementOfRSSStruct {
        static let item_rss = "item"
        static let media_content_rss = "media:content"
        static let url_rss = "url"
        static let title_rss = "title"
        static let link_rss = "link"
        static let pubDate_rss = "pubDate"
        static let description_rss = "description"
        static let category_rss = "category"
        static let media_thumbnail_rss = "media:thumbnail"
        static let media_text_rss = "media:text"
        static let match_matchid_rss = "match:matchid"
        
    }
    
    struct ImageResources {
        static let manu_logo = "manu_logo"
        static let no_image = "no_image.jpg"
    }
    
    struct FontType {
        static let AvenirNext_Regular = "AvenirNext-Regular"
        static let Gurmukhi_MN = "Gurmukhi MN"
        static let Gurmukhi_MN_Bold = "GurmukhiMN-Bold"
    }
    
    struct NibOfStoryboard {
        static let Main_Storyboard = "Main"
        static let ArticleDetailViewController = "articleDetailVC"
    }
    
    struct BarButtonItemStype {
        static let TextColor = UIColor(red:0.99, green:0.86, blue:0, alpha:1)
        static let BackButtonString = "<< Back"
    }
    
    struct Photo_Property {
        static let Caption = "Caption"
        static let Comment = "Comment"
        static let Photo = "Photo"
    }
    
    struct TwitterAccount {
        static let Consumer_Key = "hN7hXLgHozyWfTsK3YFi1aJHQ"
        static let Consumer_Secret = "MoXX67foFyL3boKg4laWXKk65wUQbrevtvqWGsfDNFyZ4QNvvr"
    }
    
    struct AlertSuccessfulView {
        static let Title = "Info"
        static let SuccessMessage = "Success!"
        static let NetworkMessage = "Mobile Network Not Available.\nPlease check your network again!"
        static let ButtonTitle = "OK"
    }
    
   
}