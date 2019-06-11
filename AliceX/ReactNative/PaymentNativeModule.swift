//
//  PaymentNativeModule.swift
//  AliceX
//
//  Created by lmcmz on 11/6/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import Foundation

@objc(PaymentNativeModule)
class PaymentNativeModule : NSObject {
    
    // This is the method exposed to React Native. It can't handle
    // the first parameter being named. http://stackoverflow.com/a/39840952/155186
    @objc func payment(_ to:String, value: String, callback successCallback: @escaping RCTResponseSenderBlock) {
//    @objc func payment(_ to:String, value: String) {
    
        // You won't be on the main thread when called from JavaScript
        DispatchQueue.main.async {
            TransactionManager.showPaymentView(toAddress: to, amount: value, success: { (tx) -> (Void) in
                successCallback([tx])
            })
        }
    }
}
