import FourChan
import SwiftUI
import SwiftyGif

struct AnimatedGifView: UIViewRepresentable {
  
  class Delegate : ObservableObject, SwiftyGifDelegate {
    @objc func gifURLDidFail(sender: UIImageView, url: URL, error: Error?) {
      if let error {
        print("Error reading gif \(url): \(error.localizedDescription)")
      }
    }
  }
  
  @StateObject var delegate = Delegate()
  
  let board: String
  let tim: Int
  let ext: String
  @Environment(\.scenePhase) var scenePhase

  init(board: String, tim: Int, ext: String) {
    self.board = board
    self.tim = tim
    self.ext = ext
  }
  
  func makeUIView(context: Context) -> UIImageView {
    let imageView = UIImageView(gifURL: url)
    imageView.delegate = delegate
    imageView.contentMode = .scaleAspectFit
    
    // As recommended by https://stackoverflow.com/questions/72732026/uiimageview-representable-not-resizing
    
    imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
    imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    return imageView
  }
  
  func updateUIView(_ uiView: UIImageView, context: Context) {
    if case .active = scenePhase {
      if !uiView.isAnimating {
        uiView.startAnimatingGif()
      }
    } else {
      if uiView.isAnimating {
        uiView.stopAnimatingGif()
      }
    }
  }
  
  // Private
  
  private var url:URL {
    FourChanAPIEndpoint.image(board:board, tim:tim, ext: ext).url()
  }
}
