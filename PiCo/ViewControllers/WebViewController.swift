//
//  WebViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/28/23.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var pageURL: URL? = nil
    
    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = pageURL {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

}
