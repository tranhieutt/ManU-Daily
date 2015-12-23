//
//  ArticleDetailTableViewCell.swift
//  MANUDaily
//
//  Created by TUYENBQ on 12/3/15.
//  Copyright © 2015 TUYENBQ. All rights reserved.
//

import UIKit

class ArticleDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var articlePublishDateLabel: UILabel!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleContentLabel: UILabel!
    var articleDetailObj : ArticleDetailStruct?{
        didSet{
            
            guard let artobj = articleDetailObj else{
                return
            }
            
            guard let pub = artobj.publishDate else{
                return
            }
            articlePublishDateLabel.text = pub
            
            guard let tit = artobj.title else{
                return
            }
            articleTitleLabel.text = tit
            
            guard let con = artobj.content else{
                return
            }
            articleContentLabel.text = con
            
            guard let imageURL = artobj.imageURL else{
                return
            }
            
            let URL = NSURL(string: imageURL)
            let placeholderImage = UIImage(named:GlobalConstants.ImageResources.no_image)!
            
            self.articleImageView.af_setImageWithURL(URL!, placeholderImage: placeholderImage)
            
            
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
                articleImageView.layer.cornerRadius = 20
                articleImageView.layer.borderWidth = 1
        articleImageView.layer.borderColor = UIColor.redColor().CGColor
                articleImageView.layer.masksToBounds = true
        

    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
