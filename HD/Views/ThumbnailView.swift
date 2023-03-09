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
  let maxSize: CGFloat
  let aspectRatio: CGFloat?
  init(board: String, tim: Int, width: Int?, height: Int?, maxSize:CGFloat = .infinity) {
    self.board = board
    self.tim = tim
    self.maxSize = maxSize
    if let width, let height, height > 0 {
      aspectRatio = CGFloat(width)/CGFloat(height)
    } else {
      aspectRatio = nil
    }
  }

  var body: some View {
    LazyImage(url:client.makeURL(endpoint:.thumbnail(board: board, tim: tim))){ state in
      if let image = state.image {
        image.resizable()
          .aspectRatio(aspectRatio, contentMode: .fill)
          .frame(maxWidth:maxSize, maxHeight:maxSize)
          .clipped()
          .cornerRadius(4)
      } else if state.error != nil {
        Color.red // Indicates an error
          .aspectRatio(aspectRatio, contentMode: .fill)
          .frame(maxWidth:maxSize, maxHeight:maxSize)
          .clipped()
          .cornerRadius(4)
      } else {
        Color(red:0.0, green: 0.0, blue: 0.0, opacity: 0.0) // Acts as a placeholder
          .aspectRatio(aspectRatio, contentMode: .fill)
          .frame(maxWidth:maxSize, maxHeight:maxSize)
          .clipped()
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
