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

class PlayerUIView: UIView, VLCMediaPlayerDelegate {
  private let mediaPlayer = VLCMediaPlayer()
  
  init(frame: CGRect, url: URL) {
    super.init(frame: frame)
        
    mediaPlayer.media = VLCMedia(url: url)
    mediaPlayer.delegate = self
    mediaPlayer.drawable = self
    mediaPlayer.play()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
