//
//  Response.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/2/25.
//

import Foundation

nonisolated struct ResponsePayload: Decodable, Sendable {
    let choices: [Choice]
}

nonisolated struct Choice: Decodable, Sendable {
    let message: Message
}

nonisolated struct Message: Decodable, Sendable {
    let role: String
    let content: String
}
