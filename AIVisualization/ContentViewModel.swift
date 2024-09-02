//
//  ContentViewModel.swift
//  AIVisualization
//
//  Created by Curt McCune on 9/2/24.
//

import Foundation

class ContentViewModel: ObservableObject {
    
    let questions = [
        "Describe yourself in 5 years",
        "Describe your work life in 5 years",
        "Describe your family life in 5 years",
//        "Describe your love life in 5 years",
//        "Describe your spiritual life in 5 years",
//        "Describe your friendships in 5 years",
//        "Describe your health in 5 years",
//        "Describe your location in 5 years",
//        "Describe anything else you can think of in 5 years"
    ]
    
    @Published var currentScreen = 0 {
        didSet {
            if currentScreen == questions.count + 1 {
                generateContent()
            }
        }
    }
    @Published var answers: [String] = Array(repeating: "", count: 3)
    @Published var audioData: Data?
    
    lazy var textGenerator: AITextGenerator = AITextGenerator()
    lazy var audioVoiceGenerator: AIAudioVoiceGenerator = AIAudioVoiceGenerator()
    
    private func generateContent() {
        Task {
            await MainActor.run {
                self.audioData = UserDefaults.standard.data(forKey: "AudioSample")
                currentScreen += 1
            }
//            let textResponse = await textGenerator.generateText(questions: questions, answers:answers)
//            
//            do {
//                let audioData = try await audioVoiceGenerator.convertTextToSpeech(text: textResponse)
//                
//                await MainActor.run {
//                    self.audioData = audioData
//                    currentScreen += 1
//                }
//            } catch let error {
//                print("hit error", error)
//            }
        }
    }
}
