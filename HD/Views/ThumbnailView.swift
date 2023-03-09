//
//  ThumbnailView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Network
import NukeUI
import SwiftUI

struct ThumbnailView: View {
  @EnvironmentObject private var client: Client
  @Environment(\.displayScale) private var displayScale: CGFloat
  let board: String
  let tim: Int
  let aspectRatio: CGFloat?
  init(board: String, tim: Int, width: Int?, height: Int?) {
    self.board = board
    self.tim = tim
    if let width, let height, height > 0 {
      aspectRatio = CGFloat(width)/CGFloat(height)
    } else {
      aspectRatio = nil
    }
  }

  var body: some View {
    LazyImage(url:client.makeURL(endpoint:.thumbnail(board: board, tim: tim))){ state in
      if let image = state.image {
        image.resizable().aspectRatio(aspectRatio, contentMode: .fit)
      } else if state.error != nil {
        Color.red // Indicates an error
      } else {
        Color.blue.aspectRatio(aspectRatio, contentMode: .fit) // Acts as a placeholder
      }
    }
  }
}

struct ThumbnailView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
