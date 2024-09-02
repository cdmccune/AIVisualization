//
//  AIAudioVoiceGenerator.swift
//  AIVisualization
//
//  Created by Curt McCune on 9/2/24.
//

import Foundation

struct AIAudioVoiceGenerator {
    // Define the structure of the request body
    struct TextToSpeechRequest: Encodable {
        let text: String
        let voice_settings: VoiceSettings?
        let model_id: String
        
        enum CodingKeys: String, CodingKey {
            case text
            case voice_settings
            case model_id
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(text, forKey: .text)
            try container.encode(voice_settings, forKey: .voice_settings)
            try container.encode(model_id, forKey: .model_id)
        }
    }
    
    struct VoiceSettings: Encodable {
        let stability: Double
        let similarity_boost: Double
    }

    // Function to send the request to Eleven Labs API using async/await
    func convertTextToSpeech(text: String) async throws -> Data? {
        // API URL
        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/XB0fDUnXU5powFXDhCwa")!
        
        // API Key
        let apiKey = "sk_1bbcf48bbbfaaec931d91deca161b24f793507638e39ac91"  // Replace with your actual API key
        
        // Create the request body
        let requestBody = TextToSpeechRequest(
            text: text,
            voice_settings: VoiceSettings(stability: 0.5, similarity_boost: 0.5),
            model_id: "eleven_monolingual_v1"
        )
        
        // Encode the request body to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let httpBody = try? encoder.encode(requestBody) else {
            throw URLError(.badURL)
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(apiKey)", forHTTPHeaderField: "xi-api-key")
        request.httpBody = httpBody
        
        // Perform the request
        print("Generating audio...")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for successful status code
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Error response:", String(data: data, encoding: .utf8) ?? "")
            throw URLError(.badServerResponse)
        }
        
        // Return the audio data
        print("Audio generated successfully")
        UserDefaults.standard.setValue(data, forKey: "AudioSample")
        return data
    }
}
