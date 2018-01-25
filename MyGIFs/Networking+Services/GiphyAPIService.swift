//
//  GiphyAPIService.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 24/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import Moya
import Alamofire

// MARK: - Considerations

// GIPHY Core SDK could also have been used
// https://github.com/Giphy/giphy-ios-sdk-core

// MARK: - Provider Support

enum GiphyAPI {
    case search(value: String, limit: Int?, offset: Int?)
    case trending(limit: Int?, offset: Int?)
}

// MARK: - TargetType Protocol Implementation

extension GiphyAPI: TargetType, AccessTokenAuthorizable {
    
    var headers: [String : String]? {
        switch self {
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: "https://api.giphy.com/")!
    }
    
    var authorizationType: AuthorizationType {
        return .none
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .search:
            return "v1/gifs/search"
            
        case .trending:
            return "v1/gifs/trending"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .search, .trending:
        return .get
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task {
        switch self {
        default:
            if var parameters = parameters {
                parameters["api_key"] = API.Giphy.APIToken
                
                return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            }
            return .requestPlain
        }
    }
    
    /// The parameters to be encoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .search(let value, let limit, let offset):
            var parameters: [String: Any] = [:]
            
            parameters["q"] = value
            parameters["limit"] = limit
            parameters["offset"] = offset
            
            return parameters
            
        case .trending(let limit, let offset):
            var parameters: [String: Any] = [:]
            parameters["limit"] = limit
            parameters["offset"] = offset

            return parameters
        }
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        default:
            return "".utf8Encoded
        }
    }
    
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    var validate: Bool {
        return false
    }
}

// MARK: - Helpers / Provider support

fileprivate extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
}
