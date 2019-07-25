//
//  TransferPopUp.swift
//  AliceX
//
//  Created by lmcmz on 25/7/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class TransferPopUp: UIViewController {
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var bgView: UIView!
    
    var address: String?
    var value: BigUInt!
    
    class func make(address: String?, value: BigUInt! = BigUInt(0)) -> TransferPopUp {
        let vc = TransferPopUp()
        vc.value = value
        vc.address = address
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressField.text = address
        valueField.text = value.readableValue
        valueFieldDidChange(self.valueField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        containView.transform = CGAffineTransform(translationX: 0, y: -400)
        bgView.alpha = 0
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
                        self.bgView.alpha = 1
                        self.containView.transform = CGAffineTransform.identity
        }, completion: { (_) in
            if self.address != nil {
                self.valueField.becomeFirstResponder()
                return
            }
            self.addressField.becomeFirstResponder()
        })
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        UIView.animate(withDuration: 0.3,
//                       delay: 0,
//                       usingSpringWithDamping: 0.9,
//                       initialSpringVelocity: 0,
//                       options: [],
//                       animations: {
//            self.bgView.alpha = 0
//            self.containView.transform = CGAffineTransform(translationX: 0, y: -400)
//        }, completion: nil)
//    }
    
    @IBAction func cancelBtnClicked() {
        view.endEditing(true)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
                        self.bgView.alpha = 0
                        self.containView.transform = CGAffineTransform(translationX: 0, y: -400)
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    @IBAction func pasteBtnClicked() {
        let address = UIPasteboard.general.string
        guard let ethAddress = address?.ethAddress else {
            return
        }
        addressField.text = ethAddress.address
    }
    
    @IBAction func cameraBtnClicked() {
        let vc = SettingViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func comfirmBtnClicked() {
        guard let ethAddress = addressField.text?.ethAddress else {
            errorAlert(text: "Addess invalid")
            return
        }

        guard let amount = Web3Utils.parseToBigUInt(valueField.text!, units: .eth) else {
            errorAlert(text: "Value invalid")
            return
        }
        
        
        TransactionManager.showPaymentView(toAddress:ethAddress.address,
                                           amount: amount,
                                           data: Data(),
                                           symbol: "ETH") { (txHash) in
                                            self.cancelBtnClicked()
        }
    }
    
    @IBAction func valueFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text , let amount = Float(text) else {
            return
        }
        let price = amount * PriceHelper.shared.exchangeRate
        priceLabel.text = price.currencyString
    }
    
    // MARK: Error
    
    func errorAlert(text: String) {
        erorAnimation()
        titleLabel.text = text
        titleLabel.textColor = Color.red
        delay(3) {
            self.erorAnimation()
            self.titleLabel.text = "🤑 Transfer"
            self.titleLabel.textColor = UIColor.lightGray
        }
    }
    
    func erorAnimation() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType(rawValue: "cube")
        transition.subtype = CATransitionSubtype.fromBottom
        titleLabel.layer.add(transition, forKey: "country1_animation")
//        transition.subtype = CATransitionSubtype.fromTop
//        country2.layer.add(transition, forKey: "country2_animation")
    }
}
