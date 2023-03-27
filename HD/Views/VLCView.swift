//
//  VLCKitView.swift
//  HD
//
//  Created by Jack Palevich on 3/19/23.
//

import SwiftUI
import VLCKitSPM

struct VLCView: UIViewRepresentable {
  let mediaURL: URL
  let width: Int
  let height: Int
    
  func updateUIView(_ uiView: PlayerUIView, context: UIViewRepresentableContext<VLCView>) {
  }
  
  func makeUIView(context: Context) -> PlayerUIView {
    return PlayerUIView(url: mediaURL)
  }
  
  func sizeThatFits(
      _ proposal: ProposedViewSize,
      uiView: PlayerUIView, context: Context
  ) -> CGSize? {
    guard
        let pWidth = proposal.width,
        let pHeight = proposal.height,
        pWidth != 0,
        pHeight != 0,
        width != 0,
        height != 0
    else { return nil }
    
    let vWidth = CGFloat(width)
    let vHeight = CGFloat(height)
    
    let scale = min(pWidth / vWidth, pHeight / vHeight)
    let displayScale = context.environment[keyPath: \.displayScale]
    func snap(_ a:CGFloat) -> CGFloat {
      return round(a*displayScale)/displayScale
    }
    let size = CGSize(width:snap(scale * vWidth), height: snap(scale * vHeight))
    return size
  }
}

class PlayerUIView: UIView, VLCMediaListPlayerDelegate {
  var url: URL
  var mediaListPlayer : VLCMediaListPlayer! = nil
  
  init(url: URL) {
    self.url = url
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  override func willMove(toSuperview newSuperview: UIView?) {
    if newSuperview == nil {
      // Avoids memory leaks.
      if mediaListPlayer != nil {
        mediaListPlayer.stop()
        mediaListPlayer.delegate = nil
        mediaListPlayer = nil
      }
    }
    super.willMove(toSuperview:newSuperview)
    if newSuperview != nil {
      mediaListPlayer = VLCMediaListPlayer(drawable:self)
      mediaListPlayer.delegate = self
      mediaListPlayer.repeatMode = .repeatCurrentItem

      let media = VLCMedia(url: url)
      let mediaList = VLCMediaList()
      mediaList.add(media)
      mediaListPlayer.mediaList = mediaList
      mediaListPlayer.play(media)
    }
  }
}

