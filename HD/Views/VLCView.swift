import SwiftUI
import VLCKitSPM
import UIKit

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


struct VLCView: View {
  let mediaURL: URL
  let width: Int
  let height: Int
  
  @State private var isMuted: Bool = true
  @State private var isPlaying: Bool = true
  
  var body: some View {
    video
      .overlay(controls.padding(8), alignment:.bottomTrailing)
  }
  
  var video: some View {
    VLCViewImpl(mediaURL: mediaURL, width: width, height: height, isPlaying: isPlaying, isMuted: isMuted)
      .aspectRatio(CGSize(width:width, height:height), contentMode: .fit)
  }
  
  var controls: some View {
    HStack{
      PlayButton(isPlaying: $isPlaying)
      MuteButton(isMuted: $isMuted)
    }
    .padding(4)
    .background(
      .thinMaterial,
      in: RoundedRectangle(cornerRadius: 4)
    )
    
  }
}

struct VLCViewImpl: UIViewControllerRepresentable {
  typealias UIViewControllerType = VLCViewController
  @Environment(\.scenePhase) private var scenePhase
  
  let mediaURL: URL
  let width: Int
  let height: Int
  let isPlaying: Bool
  let isMuted: Bool
  
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
        print("numberOfAudioTracks: \(mediaListPlayer.mediaPlayer.numberOfAudioTracks)")
        if let vlcAudio = mediaListPlayer.mediaPlayer.audio {
          let isMuted = vlcAudio.volume == 0
          if isMuted != self.isMuted {
            mediaListPlayer.pause()
            vlcAudio.volume = Int32(self.isMuted ? 0 : 100)
          }
        }
        if isPlaying {
          mediaListPlayer.play()
        } else {
          mediaListPlayer.pause()
        }
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
    if let vlcAudio = mediaListPlayer.mediaPlayer.audio {
      vlcAudio.volume = 0
    }
    mediaListPlayer.play(media)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    if mediaListPlayer != nil {
      mediaListPlayer.stop()
      mediaListPlayer.delegate = nil
      mediaListPlayer = nil
    }
  }
}
