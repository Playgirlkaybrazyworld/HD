import SwiftUI

struct PlayButton: View {
  @Binding var isPlaying: Bool

  var body: some View {
    Button{
      isPlaying.toggle()
    } label: {
      Image(systemName: isPlaying ? "pause" : "play")
      .frame(minWidth:30, minHeight:30)
    }
  }
}
