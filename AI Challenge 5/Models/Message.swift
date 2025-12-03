//
//  Message.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/3/25.
//

nonisolated struct Message: Codable, Sendable {
    let role: Role
    let content: String
}
