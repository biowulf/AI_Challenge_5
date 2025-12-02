//
//  AI_Challenge_5App.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/2/25.
//

import SwiftUI
import Alamofire

@main
struct AI_Challenge_5App: App {

    var network: NetworkService

    init() {
        let configuration = URLSessionConfiguration.af.default
        let interceptor = RequestInterceptor(key: "")
        network = NetworkService(session: Session(configuration: configuration, interceptor: interceptor))
    }

    var body: some Scene {
        WindowGroup {
            ChatDetailView(network: network)
        }
    }
}
