//
//  MiniAppViewController+Camera.swift
//  AliceX
//
//  Created by lmcmz on 20/11/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import Foundation

extension MiniAppViewController {
    
    @objc func panHandler(gesture: UIPanGestureRecognizer) {
        let center = gesture.translation(in: view)
        print(center.y)
        self.collectionView.transform = CGAffineTransform.init(translationX: 0, y: center.y)
    }
    
    @objc func coverClick() {
        isTriggle = false

        percentage = 0.0

        UIView.animate(withDuration: 0.3, animations: {
            self.scrollViewCover.alpha = 0.0
            self.cameraVC.coverView.alpha = 1.0
            self.cameraVC.view.transform = CGAffineTransform(scaleX: 1.2, y: 1.3)
            self.naviContainer.transform = CGAffineTransform.identity
            self.collectionView.transform = CGAffineTransform.identity
            self.naviContainer.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 0)
            self.cameraVC.blurView.alpha = 1.0
        }) { _ in
            self.scrollViewCover.isUserInteractionEnabled = false
            self.collectionView.isScrollEnabled = true
            self.cameraVC.disableCamera()
        }

        view.layoutIfNeeded()
    }
}

extension MiniAppViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y

        if y > 0 {
            let percentage = min(max(y / 104, 0), 1.0)
            titleLabel.alpha = percentage
            return
        }

        if isTriggle {
            return
        }

        let percentage = min(max(-y / 120, 0), 1.0)
        let slowPercentage = min(max(-y / 250, 0), 1.0)

        if y < -120 {
            if !overPlay {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                overPlay = true
            }
        } else {
            overPlay = false
        }

        if percentage > 1 {
            return
        }

        self.percentage = percentage

        print(percentage)

        updateCameraVC(slowPercentage: slowPercentage)
        updateStyle(slowPercentage: slowPercentage)
    }

    func updateStyle(slowPercentage _: CGFloat) {
        naviContainer.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 40 * percentage)
        naviContainer.transform = CGAffineTransform(translationX: 0, y: -120 * percentage)
        scrollViewCover.alpha = percentage
    }

    func updateCameraVC(slowPercentage: CGFloat) {
        cameraVC.view.transform = CGAffineTransform(scaleX: 1.2 - 0.2 * percentage,
                                                    y: 1.3 - 0.3 * percentage)

        cameraVC.blurView.alpha = 1 - slowPercentage
        cameraVC.coverView.alpha = 1 - percentage
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity _: CGPoint, targetContentOffset _: UnsafeMutablePointer<CGPoint>) {
        let offsetY = scrollView.contentOffset.y

        if offsetY < -120 {
            isTriggle = true

            percentage = 1.0

            UIView.animate(withDuration: 0.3, animations: {
                self.scrollViewCover.alpha = 1.0
                self.cameraVC.view.transform = CGAffineTransform.identity
                self.collectionView.transform = CGAffineTransform.init(translationX: 0, y: Constant.SCREEN_HEIGHT - 250)
                self.naviContainer.transform = CGAffineTransform.init(translationX: 0, y: -120)
            //                self.backButton.transform = CGAffineTransform.identity
            //                self.backIndicator.transform = CGAffineTransform.identity
            }) { (_) in
                self.scrollViewCover.isUserInteractionEnabled = true
                self.collectionView.isScrollEnabled = false
                self.cameraVC.activeCamera()
                self.cameraVC.blurView.alpha = 0
                self.cameraVC.coverView.alpha = 0
            }
        }
    }
}
