//
//  BlockchainNetwork.swift
//  AliceX
//
//  Created by lmcmz on 5/11/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

struct BalanceInfo {
    var balance: Double
}

protocol NetworkLayer {
//    func getBalance() -> Promise<Double>
    func getBalance() -> Promise<BigUInt>
}
