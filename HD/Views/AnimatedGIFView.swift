import FourChan
import SwiftUI
import SwiftyGif

struct AnimatedGifView: UIViewRepresentable {
  let board: String
  let tim: Int
  let ext: String

  init(board: String, tim: Int, ext: String, width: Int?, height: Int?) {
    self.board = board
    self.tim = tim
    self.ext = ext
  }
  
  func makeUIView(context: Context) -> UIImageView {
    let imageView = UIImageView(gifURL: url)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }
  
  func updateUIView(_ uiView: UIImageView, context: Context) {
    uiView.setGifFromURL(url)
  }
  
  private var url:URL {
    FourChanAPIEndpoint.image(board:board, tim:tim, ext: ext).url()
  }
}
