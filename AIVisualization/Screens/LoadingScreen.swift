import SwiftUI

struct LoadingScreen: View {
    let nextScreen: () -> Void
    
    var body: some View {
        VStack {
            Text("Generating your future...")
                .font(.title)
            
            ProgressView()
                .padding()
            
            // Simulating loading time
            // In a real app, you'd trigger the API calls here
            Button("Finish Loading (Demo)", action: nextScreen)
                .padding()
        }
    }
}