//
//  Network.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/2/25.
//

import Alamofire
import SwiftData
import Foundation

enum NetworkError: LocalizedError {
    case noAPIKey
    case invalidResponse
    case decodingFailed
}

class NetworkService {
    enum Format {
        case text
        case json
    }

    let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetch(for newMessages: [Message],
               format: Format = .text,
               completion: @escaping (Result<ResponsePayload, AFError>) -> Void) {

        var messages: [Message] = newMessages
        if format == .json && newMessages.first?.role != .system {
            messages.insert(addJSONSystemPromt(), at: 0)
        }

        let dto = RequestModel(model: .chat2Pro,
                               messages: messages,
                               temperature: 0,
                               maxTokens: 350,
                               repetitionPenalty: 1,
                               updateInterval: 0,
                               stream: false)

        session.request("https://gigachat.devices.sberbank.ru/api/v1/chat/completions",
                        method: .post,
                        parameters: dto,
                        encoder: .json)
        .validate()
        .responseDecodable(of: ResponsePayload.self) { response in
            print(dump(response.result))
            completion(response.result)
        }

    }

    private func addJSONSystemPromt() -> Message {
        return
            .init(
                role: .system,
                content: "Ты можешь отвечать только валидным JSON формата {\n \"role\": \"[system, user, assistant, function]]\",\n \"content\": \"...\"\n}"
            )
    }
}


