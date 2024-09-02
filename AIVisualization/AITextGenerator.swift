//
//  AITextGenerator.swift
//  AIVisualization
//
//  Created by Curt McCune on 9/2/24.
//

import Foundation

struct AITextGenerator {
    func generateText(questions: [String], answers: [String]) async -> String {
        
        guard questions.count == answers.count else { return "Error not same count" }
        
        var prompt = """
        I am going to write you a list of my wildest dreams. You will then tell the story of a day in my dream life as my future self who has all this already.
"""
        
        for (index, question) in questions.enumerated() {
            prompt += question + " Answer: " + answers[index] + "\n"
        }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        
        request.setValue("Bearer " + "sk-Y0UmekJx0BCWZaEigzNe6TI_gEujuN9LTstwcCboSwT3BlbkFJYl6FNsWmuX7zELSgLbhuQCmA8Bkojzq8NHrlAxN5oA", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var content: [[String: Any]] = [[
            "type": "text",
            "text": prompt
        ]]
        
        let jsonDict: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": content
                ]
            ],
            "max_tokens": 1000
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDict)
        request.httpBody = jsonData
        
        do {
            let response = try await URLSession.shared.data(for: request)
            let string = try handleResponse(data: response.0)
            return string
            
        } catch let error {
            print("Error on URLSession request", error)
            
            if let response = try? await URLSession.shared.data(for: request),
               let string = try? handleResponse(data: response.0) {
                return string
            } else {
                return "There was an error generating the response. Please try again later"
            }
        }
    }
    
    
    private func handleResponse(data: Data) throws -> String {
        let decoder = JSONDecoder()
                let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
        var openAIResponseString = openAIResponse.choices[0].message.content
    
        return openAIResponseString
    }
    
    enum DataDecodingError: Error {
        case couldntDecode
    }
    
    struct OpenAIResponse: Codable {
        var choices: [OpenAIChoice]
        
        struct OpenAIChoice: Codable {
            var message: OpenAIChoiceMessage
            
            struct OpenAIChoiceMessage: Codable {
                var content: String
            }
        }
    }
}
