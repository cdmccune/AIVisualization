import SwiftUI

struct QuestionScreen: View {
    let question: String
    @Binding var answer: String
    let nextScreen: () -> Void
    
    var body: some View {
        VStack {
            Text(question)
                .font(.title)
                .padding()
            
            TextEditor(text: $answer)
                .frame(height: 200)
                .border(Color.gray, width: 1)
                .padding()
            
            Button("Next", action: nextScreen)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}