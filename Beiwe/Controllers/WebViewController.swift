//
//  WebViewController.swift
//  Beiwe
//
//  Created by Zexing on 6/25/18.
//  Copyright © 2018 Rocketfarm Studios. All rights reserved.
//


import UIKit
import WebKit
class WebViewController: UIViewController, WKUIDelegate {
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let myURL = URL(string: "https://google.com")
        let myURL = URL(string: "http://findyourdreamjob.org/")
        //let myRequest = URLRequest(url: myURL!)
        webView.loadRequest(URLRequest(url: myURL!))
       
    }
   
    

}
//this code working on simulator but will crash on real phone
/*
    @IBOutlet weak var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        //webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let myURL = URL(string: "https://google.com")
        let myURL = URL(string: "http://findyourdreamjob.org/")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
 
 */


