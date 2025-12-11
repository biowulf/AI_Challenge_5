//
//  Info.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/11/25.
//

struct Info {
    var appSession: [GPTAPI : SessionGPT] = [:]
    var session: [GPTAPI : SessionGPT] = [:]
}

struct SessionGPT {
    var input: Int
    var output: Int
    var total: Int
}
