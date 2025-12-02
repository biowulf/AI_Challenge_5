//
//  MessageBubble.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/2/25.
//

import SwiftUI

struct MessageBubble: View {
    let sender: String
    let content: String

    var body: some View {
        HStack {
            if sender == "User" {
                Spacer()
            }
            Text(content)
                .padding()
                .background(sender == "User" ? Color.green.opacity(0.3) : Color.blue.opacity(0.3))
                .cornerRadius(10)
            if sender != "User" {
                Spacer()
            }
        }
    }
}
