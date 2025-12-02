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
    @State private var messages: [(sender: String, content: String)] = [] // Хранение сообщений
    var network: NetworkService

    init(network: NetworkService) {
        self.network = network
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Список сообщений
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(messages.indices, id: \.self) { index in
                        MessageBubble(sender: messages[index].sender, content: messages[index].content)
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
    func sendMessage() {
        guard !inputText.isEmpty else { return }

        messages.append(("User", inputText))

        network.fetch(from: inputText) { result in
            switch result {
            case .success(let payload):
                if let answer = payload.choices.first?.message.content {
                    self.messages.append(("GigaChat", answer))
                }
            case .failure(let error):
                print("Ошибка запроса: ", error.localizedDescription)
            }
        }

        inputText = "" // очищаем поле ввода
    }
}
