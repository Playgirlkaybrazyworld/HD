import SwiftUI

struct MuteButton: View {
  @Binding var isMuted: Bool
  
  var body: some View {
    Button{
      isMuted.toggle()
    } label: {
      Image(systemName: isMuted ? "speaker" : "speaker.slash")
      .frame(minWidth:30, minHeight:30)
    }
  }
}
