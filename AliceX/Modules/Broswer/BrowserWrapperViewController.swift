//
//  BrowserWrapperViewController.swift
//  AliceX
//
//  Created by lmcmz on 23/7/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import Foundation

// Wrapper Broswer For Switch Network
class BrowserWrapperViewController: BaseViewController {
    
    var vc: BrowserViewController!
    var urlString: String! = "https://www.duckduckgo.com/"
    
    class func make(urlString: String) -> BrowserWrapperViewController {
        let vc = BrowserWrapperViewController()
        vc.urlString = urlString
        return vc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        addBrowser()
        NotificationCenter.default.addObserver(self, selector: #selector(changeNetwork), name: .networkChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addBrowser() {
        vc = BrowserViewController()
        vc.urlString = self.urlString
        vc.willMove(toParent: self)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        self.addChild(vc)
        vc.didMove(toParent: self)
    }
    
    @objc func changeNetwork() {
        self.urlString = vc.webview.url!.absoluteString
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
        addBrowser()
    }
}
