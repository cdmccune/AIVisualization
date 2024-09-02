import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            if viewModel.currentScreen == 0 {
                StartScreen(nextScreen: { viewModel.currentScreen += 1 })
            } else if viewModel.currentScreen <= viewModel.questions.count {
                QuestionScreen(
                    question: viewModel.questions[viewModel.currentScreen - 1],
                    answer: $viewModel.answers[viewModel.currentScreen - 1],
                    nextScreen: { viewModel.currentScreen += 1 }
                )
            } else if viewModel.currentScreen == (viewModel.questions.count + 1) {
                LoadingScreen(nextScreen: { viewModel.currentScreen += 1 })
            } else {
                ListeningScreen(viewModel: ListeningViewModel(audioData: viewModel.audioData))
            }
        }
    }
    
  
}
