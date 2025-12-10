//
//  RequestInterceptor.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/2/25.
//

import Alamofire
import Network
import Foundation

final class RequestInterceptor: Alamofire.RequestInterceptor {

    let key: String
    let yaKey: String

    init(key: String,
         yaKey: String) {
        self.key = key
        self.yaKey = yaKey
    }

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {

        var urlRequest = urlRequest

        /// Set the Authorization header value using the access token.
        if urlRequest.url?.host() == "llm.api.cloud.yandex.net" {
            urlRequest.headers.add(.authorization(bearerToken: yaKey))
        } else {
            urlRequest.headers.add(.authorization(bearerToken: key))
        }

        completion(.success(urlRequest))
    }
}
