//
//  MainTabViewController.swift
//  AliceX
//
//  Created by lmcmz on 26/10/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import UIKit
import Pageboy

class MainTabViewController: PageboyViewController {

    @IBOutlet var container: UIView!
    var tabs = MainTab.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        bounces = false
    }
}

extension MainTabViewController: PageboyViewControllerDataSource {
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return tabs.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        let tab = tabs[index]
        return tab.vc
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}

//extension MainTabViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_: UIScrollView) {
//    }
//}
