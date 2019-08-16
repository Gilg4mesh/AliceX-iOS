//
//  AppDelegate+AliceSDK.swift
//  AliceX
//
//  Created by lmcmz on 16/8/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import BigInt
import Foundation

func handleAliceURL(url: URL) -> Bool {
    var dict = [String: String]()
    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    if let queryItems = components.queryItems {
        queryItems.map { item in
            dict[item.name] = item.value!
        }
    }

    guard let method = dict["method"], let callback = dict["callback"] else {
        return false
    }

    switch method {
    case "getAddress":
        let url = URL(string: "\(callback)://")!
            .appending("method", value: method)
            .appending("address", value: WalletManager.wallet!.address)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    case "signMessage":

        guard let messsage = dict["message"] else {
            return false
        }

        let data = messsage.data(using: .utf8)?.toHexString().addHexPrefix()
        TransactionManager.showSignMessageView(message: data!) { signed in
            let url = URL(string: "\(callback)://")!
                .appending("method", value: method)
                .appending("sign", value: signed)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    case "signTransaction":
        guard let to = dict["to"],
            let valueRaw = dict["value"],
            let dataRaw = dict["data"] else {
            return false
        }
        guard let value = BigUInt(valueRaw.stripHexPrefix(), radix: 16),
            let data = Data.fromHex(dataRaw) else {
            HUDManager.shared.showError(text: "Parameters is invaild")
            return false
        }
        TransactionManager.showSignTransactionView(to: to, value: value, data: data) { signed in
            let url = URL(string: "\(callback)://")!
                .appending("method", value: method)
                .appending("sign", value: signed)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

//    case "sendTransaction":

    default:
        break
    }

    return true
}
