//
//  DataProvider.swift
//  MANUDaily
//
//  Created by TUYENBQ on 11/2/15.
//  Copyright © 2015 TUYENBQ. All rights reserved.
//

import Foundation
import Ji
protocol XMLParsingDoneForMUDelegate{
    func parsingDone(sender:DataProvider, muList: NSArray)
}
class DataProvider: NSObject,NSXMLParserDelegate {
    var delegate: XMLParsingDoneForMUDelegate?
    var xmlParser: NSXMLParser!
    var element: String?
    var title: NSMutableString?
    var link: NSMutableString?
    var pubDate: NSMutableString?
    var desc: NSMutableString?
    var category: NSMutableString?
    var media: String?
    var feeds: NSMutableArray = NSMutableArray()

    // - MARK: functions
    func getAllArticles(){
        let urlString = NSURL(string: GlobalConstants.rssURLString)
        let rssUrlRequest:NSURLRequest = NSURLRequest(URL:urlString!)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(rssUrlRequest) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            guard let myData = data else{
                return
            }
            self.xmlParser = NSXMLParser(data: myData)
            self.xmlParser.delegate = self
            self.xmlParser.parse()
        }
        task.resume()

    }
    
    // - MARK: XMLParser delegate
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName;
        
        guard element == GlobalConstants.ElementOfRSSStruct.item_rss else{
            guard element == GlobalConstants.ElementOfRSSStruct.media_content_rss else{
                return
            }
            media    = attributeDict[GlobalConstants.ElementOfRSSStruct.url_rss]
            return;
        }
            
        title   = NSMutableString()
        link    = NSMutableString()
        pubDate   = NSMutableString()
        desc    = NSMutableString()
        category   = NSMutableString()
    
    }
    
    
    func parser(parser: NSXMLParser, foundCharacters string: String){
        switch element!{
            case GlobalConstants.ElementOfRSSStruct.title_rss:
                title?.appendString(string)
            break
            case GlobalConstants.ElementOfRSSStruct.link_rss:
                link?.appendString(string)
            break
        case GlobalConstants.ElementOfRSSStruct.pubDate_rss:
            pubDate?.appendString(string)
            break
        case GlobalConstants.ElementOfRSSStruct.description_rss:
            desc?.appendString(string)
            break
        case GlobalConstants.ElementOfRSSStruct.category_rss:
            category?.appendString(string)
            break
            default: break
            
        }
    }
    

    
    func parser(parser: NSXMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?){
            guard elementName == GlobalConstants.ElementOfRSSStruct.item_rss else{
                return
            }
            let articleObj = ManUAirticleObject()
            
            articleObj.man_title = title! as String
            articleObj.man_link = link! as String
            articleObj.man_pubDate = pubDate! as String
            articleObj.man_descripation = desc! as String
            articleObj.man_category = category! as String
            articleObj.man_image = media! as String
            
            feeds.addObject(articleObj)
            
    }
    
    func parserDidEndDocument(parser: NSXMLParser){
        guard let delegate = delegate else{
            return
        }
        
        delegate.parsingDone(self, muList: feeds)
    }

    
}

struct ArticleDetailStruct {
    var imageURL: String?
    var title: String?
    var summary: String?
    var content: String?
    var publishDate: String?
}

extension DataProvider{
    
    typealias serviceReponse = (ArticleDetailStruct?, NSError?) -> Void
    class func parsingHTMLPage(url:String, onCompletion: serviceReponse) -> Void{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { () -> Void in
            let parsingError: NSError = NSError.init(domain: "http://www.manutd.com/", code: 200, userInfo: ["Manchester":"forever"])
            let jiDoc = Ji(htmlURL: NSURL(string: url)!)
            
            var artDetailStruct = ArticleDetailStruct()
            
            //get image url
            let imageURL = jiDoc?.xPath("//img[@class='mainImage']")?.first
            print("image url: \(imageURL?["src"])")
            artDetailStruct.imageURL = imageURL?["src"]
            
            
            //get publish date
            let publishDate = jiDoc?.xPath("//div[@id='timestamp']")?.first
            print("publish date: \(publishDate?.content)")
            artDetailStruct.publishDate = publishDate?.content?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            //get title
            let title = jiDoc?.xPath("//div[@class='newsstory']/h1")?.first
            print("title: \(title?.content)")
            artDetailStruct.title = title?.content?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            //get summary
            let summary = jiDoc?.xPath("//div[@class='newsstory']//p/strong")?.first
            print("summary: \(summary?.content)")
            artDetailStruct.summary = summary?.content?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            
            //get content
            let content = jiDoc?.xPath("//div[@class='newsstory']")?.first?.descendantsWithName("p")
            var contentAppened = ""
            if (content?.count > 0){
                for subcontent: JiNode in content!{
                    contentAppened = contentAppened.stringByAppendingString(subcontent.content! + "\n\n")
                }
            }
            
            artDetailStruct.content = contentAppened
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                onCompletion(artDetailStruct,parsingError)
            })
            
        }
    }
    
    class func heightArticleDetailCell(font: UIFont,font1: UIFont, width: CGFloat, content: ArticleDetailStruct?) -> CGFloat{
        guard let myContent = content else{
            return 0
        }
        guard let contentContent = myContent.content else{
            return 0
        }
        
        let rect = NSString(string: contentContent).boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        guard let titleContent = myContent.title else{
            return 0
        }
        let rect1 = NSString(string: titleContent).boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font1], context: nil)
        
        return ceil(rect.height) + ceil(rect1.height)  + 400
    }
}
