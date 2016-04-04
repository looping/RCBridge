//
//  ViewController.swift
//  RCBridgeExample-Swift
//
//  Created by Looping on 4/4/16.
//  Copyright © 2016 RidgeCorn. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    let usingWebKit = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let randomCode = "\(arc4random() % 1024)"
        
        let urlRequest = NSURLRequest(URL: NSURL(string: "http://ridgecorn.com/rcb/?_=\(randomCode)")!)
        
        var webView: AnyObject
        
        if usingWebKit {
            webView = WKWebView(frame: CGRectZero, configuration: RCBridge.webViewConfiguration())
            (webView as! WKWebView).loadRequest(urlRequest)
        } else {
            webView = UIWebView(frame: CGRectZero)
            (webView as! UIWebView).loadRequest(urlRequest)
        }
        
        self.view.addSubview(webView as! UIView)
        
        let bridge = RCBridge(forWebView: webView)
        
        bridge.addMethod("you") { (handler) in
            print("received \(handler.params)")
            
            let msg: [NSObject : AnyObject] = ["code": 0, "msg": "\(arc4random() % 1024)"]
            
            handler.sendMessageBackToJS(msg)
            
            print("sent \(msg)")
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
            bridge.removeMethod("you")
            
            print("bye 'you', 😁")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

