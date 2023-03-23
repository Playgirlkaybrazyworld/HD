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

  let mediaURL: URL
  
  init(board: String, tim: Int, ext: String, width: Int?, height: Int?) {
    mediaURL = FourChanAPIEndpoint.image(board:board, tim:tim, ext: ext).url()
  }
  
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VLCView>) {
  }
  
  func makeUIView(context: Context) -> UIView {
    return PlayerUIView(frame: .zero, url: mediaURL)
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
  
}
