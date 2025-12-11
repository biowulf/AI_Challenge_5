//
//  ChatDetailView.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/2/25.
//

import SwiftUI
import SwiftData

struct ChatDetailView: View {
    @State private var inputText = ""
    @State private var messages: [Message] = [] // Хранение сообщений
    @State private var isLoading = false
    @State private var isActiveDialog = false
    @State private var gptAPI: GPTAPI = .gigachat
    @State private var isShowInfo: Bool = true
    @State private var info: Info = .init()
    @State private var collapseType: CollapseType = .none
    @State private var isActiveCollapseDialog = false
    @State private var collapsedChat: [Message] = []

    var network: NetworkService

    init(network: NetworkService) {
        self.network = network
    }

    var body: some View {
        VStack(alignment: .leading) {
            header
            HStack {
                chatView
                if isShowInfo {
                    infoView
                }
            }
        }
    }

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
//        }

        sendMessages(collapsedChat) { responseMessage in
            self.messages.append(responseMessage)
            collapsedChat.append(responseMessage)

            switch self.collapseType {
            case .none: break
            case .cut:
                if collapsedChat.count > 5 {
                    collapsedChat.remove(at: 0)
                }
            case .gpt:
                if collapsedChat.count > 5 {
                    let new = Message(role: .user, content: "напиши краткую выжимку нашего диалога выше.")
                    collapsedChat.append(new)
                    sendMessages(collapsedChat) { responseMessage in
                        collapsedChat.removeAll()
                        collapsedChat.append(responseMessage)
                    }
                }
            }
        }

        inputText = "" // очищаем поле ввода
    }

    private func sendMessages(_ messages: [Message], completion: @escaping (Message) -> Void) {
        withAnimation {
            isLoading = true
        }

        switch gptAPI {
        case .gigachat:
            network.fetch(for: messages) { result in
                isLoading = false
                switch result {
                case .success(let payload):
                    if let responseMessage = payload.choices.first?.message {
                        completion(responseMessage)
                    }
                    let usage = payload.usage

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
            network.fetchYA(for: messages) { result in
                isLoading = false
                switch result {
                case .success(let payload):
                    if let responseMessage = payload.result.alternatives.first?.message {
                        completion(.init(role: responseMessage.role, content: responseMessage.text))
                    }
                    let usage = payload.result.usage

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

    private var header: some View {
        HStack {
            gptTypeButton

            collapseTypeButton

            Spacer()

            Button {
                isShowInfo.toggle()
            } label: {
                Image(systemName: "exclamationmark.circle")
            }
            .padding()
        }
        .background(Color.gray.opacity(0.2))
    }

    private var chatView: some View {
        VStack {
            // Список сообщений
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(messages.indices, id: \.self) { index in
                        MessageBubble(message: messages[index])
                    }
                    if isLoading {
                        LoadingDots()
                    }
                }
                .padding()
            }

            // Поле ввода и кнопка отправки
            HStack {
                TextField("Сообщение...", text: $inputText)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                Button(action: sendMessage) {
                    Text("Отправить")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }

    private var infoView: some View {
        VStack(alignment: .leading) {
            Text("За сессию:")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

                Text("GPT: \(gptAPI.rawValue)")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)

                Text("Исходящие: \(info.session[gptAPI]?.input ?? 0)")
                Text("Моделью: \(info.session[gptAPI]?.output ?? 0)")
                Text("Всего токенов: \(info.session[gptAPI]?.total ?? 0)")

            Button("Сбросить") {
                info.session[gptAPI] = .init(input: 0, output: 0, total: 0)
            }
            .padding(.top)
            .padding(.bottom, 30)

            Text("За запуск приложеиня:")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

            Text("GPT: \(gptAPI.rawValue)")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

            Text("Исходящие: \(info.appSession[gptAPI]?.input ?? 0)")
            Text("Моделью: \(info.appSession[gptAPI]?.output ?? 0)")
            Text("Всего токенов: \(info.appSession[gptAPI]?.total ?? 0)")

            Spacer()
        }
        .padding()
        .background(Color.mint.opacity(0.2))
    }

    private var collapseTypeButton: some View {
        Button {
            isActiveCollapseDialog = true
        } label: {
            HStack {
                Text(collapseType.rawValue)
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
                    .padding(.leading, 2)
            }
        }
        .padding()
        .confirmationDialog("", isPresented: $isActiveCollapseDialog) {
            ForEach(CollapseType.allCases, id: \.self) { type in
                Button(role: (type == .none) ? .cancel : .confirm) {
                    collapseType = type
                } label: {
                    HStack {
                        Text(type.rawValue)
                        if type == collapseType {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                                .padding(.leading, 2)
                        }
                    }
                }
            }
        }
    }

    private var gptTypeButton: some View {
        Button {
            isActiveDialog = true
        } label: {
            HStack {
                Text(gptAPI.rawValue)
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
                    .padding(.leading, 2)
            }
        }
        .padding()
        .confirmationDialog("", isPresented: $isActiveDialog) {
            ForEach(GPTAPI.allCases, id: \.self) { api in
                Button(role: (api == .yandex) ? .cancel : .confirm) {
                    gptAPI = api
                    messages = []
                } label: {
                    HStack {
                        Text(api.rawValue)
                        if api == gptAPI {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                                .padding(.leading, 2)
                        }
                    }
                }
            }
        }
    }
}
