import SwiftUI

struct ListeningScreen: View {
    @ObservedObject var viewModel: ListeningViewModel
    
    var body: some View {
        VStack {
            Text("Your Future Life")
                .font(.largeTitle)
                .padding()
            
            Image(systemName: "waveform")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
                .padding()
            
            // Audio progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * viewModel.progress, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal)
            
            // Time labels
            HStack {
                Text(formatTime(viewModel.currentTime))
                Spacer()
                Text(formatTime(viewModel.totalDuration))
            }
            .font(.caption)
            .padding(.horizontal)
            
            Button(action: {
                viewModel.pausePlayTapped()
            }) {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            }
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
