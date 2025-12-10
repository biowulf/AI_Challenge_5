//
//  YAResponse.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/10/25.
//

import Foundation

// Основная структура ответа
nonisolated struct YAResponse: Codable, Sendable {
    let result: YAResult
}

// Вложенная структура для поля "result"
nonisolated struct YAResult: Codable, Sendable {
    let alternatives: [YAAlternative]
    let usage: YAUsage
    let modelVersion: String
}

// Структура для элемента массива "alternatives"
nonisolated struct YAAlternative: Codable, Sendable {
    let message: YAMessage
    let status: String
}

// Структура для поля "usage"
nonisolated struct YAUsage: Codable, Sendable {
    let inputTextTokens: String
    let completionTokens: String
    let totalTokens: String
    let completionTokensDetails: YACompletionTokensDetails
}

// Вложенная структура для "completionTokensDetails"
nonisolated struct YACompletionTokensDetails: Codable, Sendable {
    let reasoningTokens: String
}
