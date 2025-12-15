//
//  ChatDetailViewModel.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/15/25.
//

import Observation
import Alamofire
import Foundation
import SwiftUI

@Observable
final class ChatDetailViewModel {
    var inputText = ""
    var messages: [Message] = [] // Хранение сообщений
    var isLoading = false
    var isActiveDialog = false
    var gptAPI: GPTAPI = .gigachat
    var isShowInfo: Bool = true
    var info: Info = .init()
    var collapseType: CollapseType = .none
    var isActiveCollapseDialog = false
    var collapsedChat: [Message] = []

    private enum Constatns {
        static let kMessages = "kMessages"
        static let kCollapsedChat = "kCollapsedChat"
        static let kInfo = "kInfo"
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaults = UserDefaults.standard

    let network: NetworkService

    init(network: NetworkService) {
        self.network = network
    }

    // MARK: - Public

    func sendMessage() {
        guard !inputText.isEmpty else { return }

//        if messages.isEmpty {
//            messages.append(.init(role: .system, content: inputText))
//        } else {
            let newMessage = Message(role: .user, content: inputText)//findSystemPromt(inputText)
//            if newMessage.role == .system {
//                messages[0] = newMessage
//            }
            messages.append(newMessage)
        collapsedChat.append(newMessage)
        saveState()
//        }

        sendMessages(collapsedChat) { [weak self] responseMessage in
            guard let self else { return }
            messages.append(responseMessage)
            collapsedChat.append(responseMessage)

            switch collapseType {
            case .none: break
            case .cut:
                if collapsedChat.count > 5 {
                    collapsedChat.remove(at: 0)
                }
            case .gpt:
                if collapsedChat.count > 5 {
                    let new = Message(role: .user, content: "напиши краткую выжимку нашего диалога выше.")
                    collapsedChat.append(new)
                    sendMessages(collapsedChat) { [weak self] responseMessage in
                        guard let self else { return }
                        collapsedChat.removeAll()
                        collapsedChat.append(responseMessage)
                        saveState()
                    }
                }
            }
        }

        saveState()

        inputText = "" // очищаем поле ввода
    }

    func saveState() {

        save(messages, forKey: Constatns.kMessages)
        save(collapsedChat, forKey: Constatns.kCollapsedChat)
        save(info, forKey: Constatns.kInfo)
        userDefaults.synchronize()
    }

    func loadState() {
        if let messages: [Message] = object(forKey: Constatns.kMessages) {
            self.messages = messages
        }

        if let collapsedChat: [Message] = object(forKey: Constatns.kCollapsedChat) {
            self.collapsedChat = collapsedChat
        }

        if let info: Info = object(forKey: Constatns.kInfo) {
            self.info = info
        }
    }

    func clearChat() {
        messages.removeAll()
        collapsedChat.removeAll()
        saveState()
    }

    // MARK: - Private

    private func sendMessages(_ messages: [Message], completion: @escaping (Message) -> Void) {
        withAnimation {
            isLoading = true
        }

        switch gptAPI {
        case .gigachat:
            network.fetch(for: messages) { [weak self] result in
                guard let self else { return }
                isLoading = false
                switch result {
                case .success(let payload):
                    if let responseMessage = payload.choices.first?.message {
                        completion(responseMessage)
                    }
                    let usage = payload.usage

                    var requestInfo = info.request[gptAPI] ?? .init(input: 0, output: 0, total: 0)
                    requestInfo.input = usage.promptTokens
                    requestInfo.output = usage.completionTokens
                    requestInfo.total = usage.totalTokens
                    info.request[gptAPI] = requestInfo

                    var session = info.session[gptAPI] ?? .init(input: 0, output: 0, total: 0)
                    session.input += usage.promptTokens
                    session.output += usage.completionTokens
                    session.total += usage.totalTokens
                    info.session[gptAPI] = session

                    var appSession = info.appSession[gptAPI] ?? .init(input: 0, output: 0, total: 0)
                    appSession.input += usage.promptTokens
                    appSession.output += usage.completionTokens
                    appSession.total += usage.totalTokens
                    info.appSession[gptAPI] = appSession
                case .failure(let error):
                    print("Ошибка запроса: ", error.localizedDescription)
                }
            }
        case .yandex:
            network.fetchYA(for: messages) { [weak self] result in
                guard let self else { return }
                isLoading = false
                switch result {
                case .success(let payload):
                    if let responseMessage = payload.result.alternatives.first?.message {
                        completion(.init(role: responseMessage.role, content: responseMessage.text))
                    }
                    let usage = payload.result.usage

                    var requestInfo = info.request[gptAPI] ?? .init(input: 0, output: 0, total: 0)
                    requestInfo.input = Int(usage.inputTextTokens) ?? 0
                    requestInfo.output = Int(usage.completionTokens) ?? 0
                    requestInfo.total = Int(usage.totalTokens) ?? 0
                    info.request[gptAPI] = requestInfo

                    var session = info.session[gptAPI] ?? .init(input: 0, output: 0, total: 0)
                    session.input += Int(usage.inputTextTokens) ?? 0
                    session.output += Int(usage.completionTokens) ?? 0
                    session.total += Int(usage.totalTokens) ?? 0
                    info.session[gptAPI] = session

                    var appSession = info.appSession[gptAPI] ?? .init(input: 0, output: 0, total: 0)
                    appSession.input += Int(usage.inputTextTokens) ?? 0
                    appSession.output += Int(usage.completionTokens) ?? 0
                    appSession.total += Int(usage.totalTokens) ?? 0
                    info.appSession[gptAPI] = appSession
                case .failure(let error):
                    print("Ошибка запроса: ", error.localizedDescription)
                }
            }
        }
    }

    private func findSystemPromt(_ string: String) -> Message {
        let sentencesInText = string.components(separatedBy: ". ")
        let defaultMessage = Message(role: .user, content: string)
        guard let first = sentencesInText.first,
              first.contains("представь") || first.contains("ты")
        else { return defaultMessage }
        return Message(role: .system, content: first)
    }

    private func save(_ object: Encodable, forKey: String) {
        do {
            let data = try encoder.encode(object)
            userDefaults.set(data, forKey: forKey)
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }

    private func object<T:Decodable>(forKey: String) -> T? {
        guard let savedData = userDefaults.data(forKey: forKey) else { return nil }
        do {
            let object = try decoder.decode(T.self, from: savedData)
            return object
        } catch {
            print("Ошибка сохранения: \(error)")
        }
        return nil
    }
}
