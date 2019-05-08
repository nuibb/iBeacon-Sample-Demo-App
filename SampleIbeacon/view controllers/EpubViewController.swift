//
//  ViewController.swift
//  SampleIbeacon
//
//  Created by MobioApp on 9/26/17.
//  Copyright © 2017 MobioApp. All rights reserved.
//

import UIKit
import WebKit

class EpubViewController : UIViewController,WKNavigationDelegate {
    
    var fileLocation : URL?
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
   
    override func viewWillAppear(_ animated: Bool) {
        
       // print("file location in epub vc : \(String(describing: fileLocation!))")
        let data = try! Data(contentsOf: fileLocation!)
        webView = WKWebView(frame: CGRect( x: 0, y: 60, width: self.view.frame.width, height: self.view.frame.height - 20 ), configuration: WKWebViewConfiguration() )
        webView.backgroundColor = UIColor.gray
        webView.load(data, mimeType: "application/pdf", characterEncodingName:"", baseURL: (fileLocation?.deletingLastPathComponent())!)
        self.view.addSubview(webView)
        self.view.sendSubview(toBack: webView)
    }
    
    //MARK:- WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        print("Strat to load")
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("finish to load")
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

