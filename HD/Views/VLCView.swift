import SwiftUI
import VLCKitSPM
import UIKit

struct VLCView: View {
  let mediaURL: URL
  let width: Int
  let height: Int
  
  @State private var showControls = false
  @State private var isMuted: Bool = true
  @State private var isPlaying: Bool = true
  @State private var numberOfAudioTracks: Int? = nil

  var body: some View {
    video
      .onTapGesture() {
        showControls.toggle()
      }
      .overlay(
        controls.padding(8)
        .opacity(showControls ? 1 : 0),
        alignment:.bottomTrailing)

  }
  
  var video: some View {
    VLCViewImpl(mediaURL: mediaURL, width: width, height: height, isPlaying: isPlaying, isMuted: isMuted, numberOfAudioTracks: $numberOfAudioTracks)
      .aspectRatio(CGSize(width:width, height:height), contentMode: .fit)
  }
  
  var controls: some View {
    HStack{
      PlayButton(isPlaying: $isPlaying)
      if numberOfAudioTracks ?? 0 > 0 {
        MuteButton(isMuted: $isMuted)
      }
    }
    .padding(4)
    .background(
      .thinMaterial,
      in: RoundedRectangle(cornerRadius: 4)
    )
    
  }
}


class Coordinator: NSObject, VLCMediaPlayerDelegate {
  @Binding
  public var numberOfAudioTracks: Int?
  public var mediaPlayer: VLCMediaPlayer!
  
  init(numberOfAudioTracks: Binding<Int?>) {
    self._numberOfAudioTracks = numberOfAudioTracks
  }
  
  func mediaPlayerStateChanged(_ aNotification: Notification ) {
    if case .playing = mediaPlayer.state {
      print("mediaPlayer.numberOfAudioTracks \(mediaPlayer.numberOfAudioTracks)")
      numberOfAudioTracks = Int(mediaPlayer.numberOfAudioTracks)
    }
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
  @Binding var numberOfAudioTracks: Int?
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(numberOfAudioTracks: _numberOfAudioTracks)
  }
  
  func makeUIViewController(context: Context) -> VLCViewController {
    let vc = VLCViewController()
    vc.coordinator = context.coordinator
    vc.mediaURL = mediaURL
    vc.width = width
    vc.height = height
    return vc
  }
  
  func updateUIViewController(_ uiViewController: VLCViewController, context: Context) {
    if let mediaListPlayer = uiViewController.mediaListPlayer,
       let view = uiViewController.view {
      if scenePhase == .active {
        numberOfAudioTracks = Int(mediaListPlayer.mediaPlayer.numberOfAudioTracks)
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

class VLCViewController: UIViewController {
  var mediaURL: URL!
  var width: Int = 0
  var height: Int = 0
  
  var mediaListPlayer: VLCMediaListPlayer!
  var coordinator: Coordinator!
  
  override func loadView() {
    view = UIView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    guard let view = view else { return }
    mediaListPlayer = VLCMediaListPlayer(drawable:view)
    mediaListPlayer.repeatMode = .repeatCurrentItem
    if let coordinator {
      coordinator.mediaPlayer = mediaListPlayer.mediaPlayer
      mediaListPlayer.mediaPlayer.delegate = coordinator
    }

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
      mediaListPlayer.mediaPlayer.delegate = nil
      mediaListPlayer = nil
      if let coordinator {
        coordinator.mediaPlayer = nil
      }
    }
  }
}
