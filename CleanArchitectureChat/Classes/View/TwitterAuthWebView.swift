//
//  TwitterAuthWebView.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/01.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit
import WebKit

class TwitterAuthWebView: UIViewController {

    let webView = WKWebView()
    let loadingIndicator = UIActivityIndicatorView()
    //URL: tlc-app://?oauth_token=xxx&oauth_verifier=yyy
    var callback: ((URL)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.frame = self.view.frame
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)

        self.loadingIndicator.color = .blue
        self.view.addSubview(self.loadingIndicator)

    }

    func loadURL(url: URL) {
        self.showLoadingIndicator()
        self.webView.load(URLRequest(url: url))
    }

    private func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.view.bringSubview(toFront: self.loadingIndicator)
            self.loadingIndicator.center = self.view.center
            self.loadingIndicator.startAnimating()
        }
    }

    private func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
        }
    }

}

extension TwitterAuthWebView: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideLoadingIndicator()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.absoluteString.hasPrefix("tlc-app") == true {
            decisionHandler(.cancel)
            self.dismiss(animated: true, completion: {
                self.callback?(url)
            })
            return
        }
        decisionHandler(.allow)
    }

}
