//
//  YARequestModel.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/10/25.
//

nonisolated struct YARequestModel: Codable, Sendable {
    let modelUri: String = "gpt://<>/yandexgpt/rc"
    let completionOptions: CompletionOptions
    let messages: [YAMessage]
}

nonisolated struct CompletionOptions: Codable, Sendable {
    let stream: Bool
    let temperature: Float
    let maxTokens: Int
}

nonisolated struct YAMessage: Codable, Sendable {
    let role: Role
    let text: String
}
