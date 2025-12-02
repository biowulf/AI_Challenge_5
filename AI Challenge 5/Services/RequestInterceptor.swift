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

    var key: String

    init(key: String) {
        self.key = key
    }

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {

        var urlRequest = urlRequest

        /// Set the Authorization header value using the access token.
        if !key.isEmpty {
            urlRequest.headers.add(.authorization(bearerToken: key))
        }

        completion(.success(urlRequest))
    }
}
