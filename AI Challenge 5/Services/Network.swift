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
    let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetch(from message: String, completion: @escaping (Result<ResponsePayload, AFError>) -> Void) {

        let parameters: Parameters = [
                    "model": "GigaChat-2",
                    "messages": [
                        ["role": "system",
                         "content": "Ты можешь отвечать только валидным JSON формата `{\n \"role\": \"[system, user, assistant, function]]\",\n \"content\": \"...\"\n}`"
                            ],
                        ["role": "user", "content": message]
                    ],
                    "n": 1,
                    "stream": false,
                    "max_tokens": 1024,
                    "repetition_penalty": 1,
                    "update_interval": 0
                ]

        session.request("https://gigachat.devices.sberbank.ru/api/v1/chat/completions",
                        method: .post,
                        parameters: parameters,
                        encoding: JSONEncoding())
        .validate()
        .responseDecodable(of: ResponsePayload.self) { response in
            print(dump(response.result))
            completion(response.result)
        }

    }
}


