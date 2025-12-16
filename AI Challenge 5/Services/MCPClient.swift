//
//  MCPClient.swift
//  AI Challenge 5
//
//  Created by Bolyachev Rostislav on 12/16/25.
//

import MCP
import Foundation

final class MCPClient {

    func getTools(_ url: String) async throws {

        // Initialize the client
        let client = Client(name: "AIChallenge5", version: "1.0.0")
        // Create a transport and connect
        //        let transport = StdioTransport()
        let transport = HTTPClientTransport(
            endpoint: URL(string: url)!,
            streaming: true  // Enable Server-Sent Events for real-time updates
        )
        let result = try await client.connect(transport: transport)

        // Check server capabilities
        if result.capabilities.tools != nil {
            // Server supports tools (implicitly including tool calling if the 'tools' capability object is present)
        }

        // List available tools
        let (tools, _) = try await client.listTools()
        print("\nMCP Server \(result.serverInfo.name) \(result.serverInfo.version)\n")
        print("Available tools: \n- \(tools.map { $0.name }.joined(separator: "\n- "))")
        await client.disconnect()
    }
}
