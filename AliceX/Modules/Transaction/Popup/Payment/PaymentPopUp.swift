//
//  PaymentPopUp.swift
//  AliceX
//
//  Created by lmcmz on 19/6/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import BigInt
import PromiseKit
import SPStorkController
import UIKit
import web3swift

// Can't be BaseVIewController
class PaymentPopUp: UIViewController {
    @IBOutlet var payButton: UIControl!

    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var coinImageView: UIImageView!
    
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!

    @IBOutlet var gasPriceLabel: UILabel!
    @IBOutlet var gasTimeLabel: UILabel!

    @IBOutlet var gasBtn: UIControl!

    var toAddress: String?
    var amount: BigUInt!
    var data: Data!
    var successBlock: StringBlock?

    var gasLimit: BigUInt?
    var gasPrice: GasPrice = GasPrice.average

    var coin: Coin!
    var payView: PayButtonView?

    class func make(toAddress: String,
                    amount: BigUInt,
                    data: Data,
                    coin: Coin,
                    success: @escaping StringBlock) -> PaymentPopUp {
        let vc = PaymentPopUp()
        vc.toAddress = toAddress
        vc.amount = amount
        vc.successBlock = success
        vc.data = data
        vc.coin = coin
        return vc
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        SPStorkController.updatePresentingController(modal: self)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let chain = coin.blockchain else {
            HUDManager.shared.showError(text: "Wrong coin type")
            self.dismiss(animated: true, completion: nil)
            return
        }

        coinImageView.kf.setImage(with: coin.image)
        
        symbolLabel.text = coin.info!.symbol
        nameLabel.text = coin.info!.name
        
        addressLabel.text = toAddress
        let value = amount.readableValue
        amountLabel.text = value.round(decimal: 4)
        let price = Float(value)! * PriceHelper.shared.exchangeRate
        priceLabel.text = price.currencyString

        payView = PayButtonView.instanceFromNib()
        payButton.addSubview(payView!)
        payView!.fillSuperview()
        payView?.delegate = self

        
        if chain != .Ethereum {
            gasBtn.isHidden = true
            return
        }
        
        /// If not Ethereum, not support change gas price
        
        gasTimeLabel.text = "Arrive in ~ \(gasPrice.time) mins"

        gasBtn.isUserInteractionEnabled = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(gasChange(_:)),
                                               name: .gasSelectionCahnge, object: nil)

        firstly {
            GasPriceHelper.shared.getGasPrice()
        }.then {
            TransactionManager.shared.gasForSendingEth(to: self.toAddress!, amount: self.amount!, data: self.data)
        }.done { gasLimit in
            self.gasLimit = gasLimit
            self.gasPriceLabel.text = self.gasPrice.toCurrencyFullString(gasLimit: gasLimit)
            self.gasBtn.isUserInteractionEnabled = true
            self.gasTimeLabel.text = "Arrive in ~ \(self.gasPrice.time) mins"
        }.catch { _ in
            self.gasPriceLabel.text = "Failed to get gas"
            self.gasPriceLabel.textColor = UIColor(hex: "FF7E79")
        }
    }

    // MARK: - GAS Notification

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func gasButtonClick() {
        let vc = GasFeeViewController.make(gasLimit: gasLimit!)
        HUDManager.shared.showAlertVCNoBackground(viewController: vc)
    }

    @objc func gasChange(_ notification: Notification) {
        guard let text = notification.userInfo?["gasPrice"] as? String else { return }
        let gasPrice = GasPrice(rawValue: text)!
        self.gasPrice = gasPrice
        updateGas()
    }

    func updateGas() {
        gasTimeLabel.text = "Arrive in ~ \(gasPrice.time) mins"
        gasPriceLabel.text = gasPrice.toCurrencyFullString(gasLimit: gasLimit!)
    }
}

extension PaymentPopUp: PayButtonDelegate {
    // MARK: - Verify

    func verifyAndSend() {
        #if DEBUG
            send()
        #else
            biometricsVerify()
        #endif
    }

    func biometricsVerify() {
        firstly {
            FaceIDHelper.shared.faceID()
        }.done { _ in
            self.send()
        }
    }

    func send() {
        payView!.showLoading()
        
        guard let chain = coin.blockchain else {
            return
        }
        
        firstly {
            chain.transfer(toAddress: toAddress!, value: amount!, gasPrice: gasPrice)
        }
        
        
//        firstly {
//            TransactionManager.shared.sendEtherSync(
//                to: toAddress!,
//                amount: amount!,
//                data: data!,
//                password: "",
//                gasPrice: gasPrice
//            )
//        }.done { hash in
//            print(hash)
//            self.successBlock!(hash)
//            self.dismiss(animated: true, completion: nil)
//        }.catch { error in
//            self.payView!.failed()
//            HUDManager.shared.showError(error: error)
//        }
    }
}
