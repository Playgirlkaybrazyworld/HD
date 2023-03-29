//
//  ThumbnailView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import FourChan
import Network
import NukeUI
import SwiftUI

struct ThumbnailView: View {
  @EnvironmentObject private var client: Client
  @Environment(\.displayScale) private var displayScale: CGFloat
  let board: String
  let tim: Int
  let maxSize: CGFloat
  let aspectRatio: CGFloat?
  init(board: String, tim: Int, width: Int?, height: Int?, maxSize:CGFloat? = nil) {
    self.board = board
    self.tim = tim
    self.maxSize = maxSize ?? CGFloat(max(width ?? 0, height ?? 0))
    if let width, let height, height > 0 {
      aspectRatio = CGFloat(width)/CGFloat(height)
    } else {
      aspectRatio = nil
    }
  }

  var body: some View {
    LazyImage(url:client.makeURL(endpoint:FourChanAPIEndpoint.thumbnail(board: board, tim: tim))){ state in
      if let image = state.image {
        image.resizable()
          .scaledToFill()
          .frame(width:maxSize, height:maxSize)
          .cornerRadius(4)
      } else if state.error != nil {
        Color.secondary // Indicates an error
          .scaledToFill()
          .frame(width:maxSize, height:maxSize)
          .cornerRadius(4)
      } else {
        Color(red:0.0, green: 0.0, blue: 0.0, opacity: 0.0) // Acts as a placeholder
          .scaledToFill()
          .frame(width:maxSize, height:maxSize)
          .cornerRadius(4)
      }
    }
  }
}

struct ThumbnailView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
