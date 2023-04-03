import SwiftUI
import VLCKitSPM
import UIKit

struct VLCView: View {
  let mediaURL: URL
  let width: Int
  let height: Int
  
  var body: some View {
    VLCViewImpl(mediaURL: mediaURL, width: width, height: height)
      .aspectRatio(CGSize(width:width, height:height), contentMode: .fit)
  }

}

struct VLCViewImpl: UIViewControllerRepresentable {
  typealias UIViewControllerType = VLCViewController
  @Environment(\.scenePhase) private var scenePhase

  let mediaURL: URL
  let width: Int
  let height: Int
  
  func makeUIViewController(context: Context) -> VLCViewController {
    let vc = VLCViewController()
    vc.mediaURL = mediaURL
    vc.width = width
    vc.height = height
    return vc
  }
  
  func updateUIViewController(_ uiViewController: VLCViewController, context: Context) {
    if let mediaListPlayer = uiViewController.mediaListPlayer,
       let view = uiViewController.view {
      if scenePhase == .active {
        mediaListPlayer.play()
        view.alpha = 1.0
      } else {
        mediaListPlayer.pause()
        // Need to do this here rather than at the SwiftUI
        // level. Otherwise 2nd time we go into the backgroun
        // the view remains opaque.
        view.alpha = 0.0
      }
    }
  }
}

class VLCViewController: UIViewController, VLCMediaListPlayerDelegate {
  var mediaURL: URL!
  var width: Int = 0
  var height: Int = 0

  var mediaListPlayer: VLCMediaListPlayer!

  override func loadView() {
    view = UIView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    guard let view = view else { return }
    mediaListPlayer = VLCMediaListPlayer(drawable:view)
    mediaListPlayer.delegate = self
    mediaListPlayer.repeatMode = .repeatCurrentItem
    
    let media = VLCMedia(url: mediaURL)
    let mediaList = VLCMediaList()
    mediaList.add(media)
    mediaListPlayer.mediaList = mediaList
    mediaListPlayer.play(media)
    if let vlcAudio = mediaListPlayer.mediaPlayer.audio {
      vlcAudio.volume = 0
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    if mediaListPlayer != nil {
      mediaListPlayer.stop()
      mediaListPlayer.delegate = nil
      mediaListPlayer = nil
    }
  }
}
