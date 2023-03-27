//
//  VLCView.swift
//  HD
//
//  Created by Jack Palevich on 3/27/23.
//

import SwiftUI
import VLCKitSPM
import UIKit

struct VLCView: UIViewControllerRepresentable {
  typealias UIViewControllerType = VLCViewController
  
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
    // Don't need to do anything
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
    mediaListPlayer = VLCMediaListPlayer(drawable:view)
    mediaListPlayer.delegate = self
    mediaListPlayer.repeatMode = .repeatCurrentItem
    
    let media = VLCMedia(url: mediaURL)
    let mediaList = VLCMediaList()
    mediaList.add(media)
    mediaListPlayer.mediaList = mediaList
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
