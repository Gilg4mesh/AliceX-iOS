//
//  PinItem.swift
//  AliceX
//
//  Created by lmcmz on 2/9/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import Foundation

protocol PinDelegate {
    func pinItem() -> PinItem
}

enum PinItem {
    case website(image: UIImage, url: URL, title: String, viewcontroller: UIViewController)
    case dapplet(image: UIImage, url: URL, title: String, viewcontroller: UIViewController)
    case transaction(network: Web3NetEnum, txHash: String, title: String, viewcontroller: UIViewController)
    case walletConnect(image: URL, id: String, title: String, viewcontroller: UIViewController)

    var txHash: String {
        switch self {
        case .transaction(_, let txHash, _, _):
            return txHash
        default:
            return ""
        }
    }

    var isWalletConnect: Bool {
        switch self {
        case .walletConnect:
            return true
        default:
            return false
        }
    }

    var wcKey: String {
        switch self {
        case .walletConnect(_, let key, _, _):
            return key
        default:
            return ""
        }
    }

    var network: Web3NetEnum {
        switch self {
        case .transaction(let network, _, _, _):
            return network
        default:
            return .main
        }
    }

    var URL: URL? {
        switch self {
        case .transaction(let network, let txHash, _, _):
            if !network.isUsingInfura {
                return network.rpcURL
            }
            if network == .main {
//                return URL(string: "https://etherscan.io/tx/\(txHash)")
                return Foundation.URL(string: "https://etherscan.io/tx/\(txHash)")
            }
            return Foundation.URL(string: "https://\(network.name).etherscan.io/tx/\(txHash)")
        case .dapplet(_, let url, _, _):
            return url
        case .website(_, let url, _, _):
            return url
        case .walletConnect:
            return nil
        }
    }

    var vc: UIViewController {
        switch self {
        case let .dapplet(_, _, _, vc),
             let .transaction(_, _, _, vc),
             let .website(_, _, _, vc),
             let .walletConnect(_, _, _, vc):
            return vc
        }
    }

    static func txURL(network: Web3NetEnum, txHash: String) -> URL {
        if !network.isUsingInfura {
            return network.rpcURL
        }
        if network == .main {
            //                return URL(string: "https://etherscan.io/tx/\(txHash)")
            return Foundation.URL(string: "https://etherscan.io/tx/\(txHash)")!
        }
        return Foundation.URL(string: "https://\(network.name).etherscan.io/tx/\(txHash)")!
    }
}

extension PinItem: Hashable, Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.vc == rhs.vc
    }

    var hashValue: Int {
        switch self {
        case .website(_, let url, _, _):
            return url.absoluteString.hashValue
        case .dapplet(_, let url, _, _):
            return url.absoluteString.hashValue
        case .transaction(_, let txHash, _, _):
            return txHash.hashValue
        case .walletConnect(_, let id, _, _):
            return id.hashValue
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .website(_, let url, _, _):
            hasher.combine(url)
        case .dapplet(_, let url, _, _):
            hasher.combine(url)
        case .transaction(_, let txHash, _, _):
            hasher.combine(txHash)
        case .walletConnect(_, let id, _, _):
            hasher.combine(id)
        }
    }
}
