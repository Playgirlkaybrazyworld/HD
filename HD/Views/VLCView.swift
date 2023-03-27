//
//  VLCKitView.swift
//  HD
//
//  Created by Jack Palevich on 3/19/23.
//

import Foundation
import FourChan
import SwiftUI
import UIKit
import VLCKitSPM

struct VLCView: UIViewRepresentable {
  /// Currently used only for debugging
  let postNo: Int
  let mediaURL: URL
  let width: CGFloat?
  let height: CGFloat?
  
  init(board: String, postNo: Int, tim: Int, ext: String, width: Int?, height: Int?) {
    self.postNo = postNo
    self.width = CGFloat(width ?? 160)
    self.height = CGFloat(height ?? 160)
    mediaURL = FourChanAPIEndpoint.image(board:board, tim:tim, ext: ext).url()
  }
  
  func updateUIView(_ uiView: PlayerUIView, context: UIViewRepresentableContext<VLCView>) {
  }
  
  func makeUIView(context: Context) -> PlayerUIView {
    return PlayerUIView(frame: .zero, url: mediaURL)
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
        let vWidth = self.width,
        let vHeight = self.height,
        vWidth != 0,
        vHeight != 0
    else { return nil }
    
    if pWidth == vWidth && pHeight == vHeight {
      return CGSize(width: vWidth, height: vHeight)
    }
    let scale = min(pWidth / vWidth, pHeight / vHeight)
    func snap(_ a:CGFloat) -> CGFloat {
      let scale = UIScreen.main.scale
      return round(a*scale)/scale
    }
    let size = CGSize(width:snap(scale * vWidth), height: snap(scale * vHeight))
    return size
  }
}

class PlayerUIView: UIView, VLCMediaListPlayerDelegate {
  var mediaListPlayer : VLCMediaListPlayer! = nil
  
  init(frame: CGRect, url: URL) {
    super.init(frame: frame)
    
    let media = VLCMedia(url: url)

    let mediaList = VLCMediaList()
    mediaList.add(media)

    mediaListPlayer = VLCMediaListPlayer(drawable:self)
    mediaListPlayer.delegate = self

    mediaListPlayer.mediaList = mediaList

    mediaListPlayer.repeatMode = .repeatCurrentItem
    mediaListPlayer.play(media)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func willMove(toSuperview newSuperview: UIView?) {
    if newSuperview == nil {
      mediaListPlayer.stop()
      mediaListPlayer.delegate = nil
      mediaListPlayer = nil
    }
    super.willMove(toSuperview:newSuperview)
  }
}

