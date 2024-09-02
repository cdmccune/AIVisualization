import SwiftUI

struct StartScreen: View {
    let nextScreen: () -> Void
    
    var body: some View {
        VStack {
            Text("Welcome to Future Life")
                .font(.largeTitle)
            
            Button("Start", action: nextScreen)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}