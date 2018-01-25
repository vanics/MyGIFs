//
//  Networking.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 24/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import Moya
import Result
import Moya_ObjectMapper

// MARK: - Provider Setup

struct Network {
    static private(set) var provider = MoyaProvider<GiphyAPI>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])
    
    static func request(
        _ target: GiphyAPI,
        success successCallback: ((Response) -> Void)? = nil,
        error errorCallback:  ((Response?) -> Void)? = nil,
        failure failureCallback:  ((MoyaError) -> Void)? = nil) {
        
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    //let json = try? response.mapJSON()
                    successCallback?(response)
                }
                catch {
                    errorCallback?(response)
                }
            case let .failure(error):
                failureCallback?(error)
            }
        }
    }
}

// TODO: Production version should not have the NetworkLoggerPlugin
var GiphyProvider = MoyaProvider<GiphyAPI>(
    plugins: [
        NetworkLoggerPlugin(verbose: true,
                            responseDataFormatter: JSONResponseDataFormatter
        )
    ]
)

// MARK: - Helpers

//public func url(_ route: TargetType) -> String {
//    return route.baseURL.appendingPathComponent(route.path).absoluteString
//}

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}
