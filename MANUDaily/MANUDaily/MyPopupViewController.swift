//
//  MyPopupViewController.swift
//  SLPopupViewControllerDemo
//
//  Created by Nguyen Duc Hoang on 9/13/15.
//  Copyright © 2015 Nguyen Duc Hoang. All rights reserved.
//

import UIKit

protocol MyPopupViewControllerDelegate {
    func pressOK(sender: MyPopupViewController, text: String)
    func pressCancel(sender: MyPopupViewController)
}
class MyPopupViewController: UIViewController,UITextViewDelegate {
    var delegate:MyPopupViewControllerDelegate?
    var url:String?
    @IBOutlet weak var textViewEnter: UITextView!
    
    @IBOutlet weak var webView: UIWebView!
    @IBAction func btnOK(sender:UIButton) {
        self.delegate?.pressOK(self,text: textViewEnter.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
    }
    
    @IBAction func btnCancel(sender:UIButton) {
        self.delegate?.pressCancel(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 22
        self.view.layer.masksToBounds = true
        // Do any additional setup after loading the view.
        textViewEnter.delegate = self
        guard let myURL = url else{
            return
        }
        webView.loadRequest(NSURLRequest.init(URL: NSURL.init(string: myURL)!))
    }

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textViewEnter.text = ""
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
