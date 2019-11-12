//
//  Binance.swift
//  AliceX
//
//  Created by lmcmz on 28/10/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import Moya

// Doc Address: https://docs.binance.org/api-reference/dex-api/paths.html

//let BNBAPI = MoyaProvider<BNBAPI>(plugins:
//    [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

enum BNBAPI {
    case account(address: String)
//    case getAddressInfo(address: String)
}

extension BNBAPI: TargetType {
    var headers: [String: String]? {
        switch self {
        default:
            return ["Content-Type": "application/json"]
        }
    }

    var baseURL: URL {
        #if DEBUG
        return URL(string: "https://testnet-dex.binance.org/api/v1/")!
        #else
        return URL(string: "https://dex.binance.org/api/v1/")!
        #endif
    }

    var path: String {
        switch self {
        case .account(let address):
            return "account/\(address)"
        }
    }

    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }

    var task: Task {
        switch self {
        default:
            return .requestPlain
        }
    }

    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
}
