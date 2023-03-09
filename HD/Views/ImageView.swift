//
//  ImageView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Network
import NukeUI
import SwiftUI

struct ImageView: View {
  @EnvironmentObject private var client: Client
  @Environment(\.displayScale) private var displayScale: CGFloat
  let board: String
  let tim: Int
  let ext: String
  var body: some View {
    LazyImage(url:client.makeURL(endpoint:.image(board: board, tim: tim, ext: ext))){ state in
      if let image = state.image {
        image.resizable().aspectRatio(contentMode: .fit)
      } else if state.error != nil {
        Color.red // Indicates an error
      } else {
        Color.blue // Acts as a placeholder
      }
    }
  }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        Text("TBD")
    }
}
