//
//  RequestModel.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/3/25.
//

nonisolated struct RequestModel: Encodable, Sendable {
    let model: GigaChatModel
    let messages: [Message]
    let temperature: Int
    let maxTokens: Int
    let repetitionPenalty: Float
    let updateInterval: Int
    let stream: Bool
}
