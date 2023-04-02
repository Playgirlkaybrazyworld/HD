import Network
import NukeUI
import SwiftUI

struct ImageView: View {
  @EnvironmentObject private var client: Client
  @Environment(\.displayScale) private var displayScale: CGFloat
  let board: String
  let tim: Int
  let ext: String
  let aspectRatio: CGFloat?
  let width: CGFloat?
  let height: CGFloat?
  
  init(board: String, tim: Int, ext: String, width: Int?, height: Int?) {
    self.board = board
    self.tim = tim
    self.ext = ext
    if let width, let height, height > 0 {
      self.width = CGFloat(width)
      self.height = CGFloat(height)
      aspectRatio = CGFloat(width)/CGFloat(height)
    } else {
      self.width = nil
      self.height = nil
      aspectRatio = nil
    }
  }
  
  var body: some View {
    LazyImage(url:client.makeURL(endpoint:.image(board: board, tim: tim, ext: ext))){ state in
      if let image = state.image {
        image
          .resizable()
          .aspectRatio(aspectRatio, contentMode: .fit)
          .frame(maxWidth:width, maxHeight:height)
      } else if state.error != nil {
        Color.red // Indicates an error
      } else {
        Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.0).aspectRatio(aspectRatio, contentMode: .fit) // Acts as a placeholder
      }
    }
  }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        Text("TBD")
    }
}
