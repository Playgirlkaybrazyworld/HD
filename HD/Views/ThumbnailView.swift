//
//  ThumbnailView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Network
import SwiftUI

struct ThumbnailView: View {
  @EnvironmentObject private var client: Client
  @Environment(\.displayScale) private var displayScale: CGFloat
  let board: String
  let tim: Int
  var body: some View {
    AsyncImage(url:client.makeURL(endpoint:.thumbnail(board: board, tim: tim)), scale:displayScale)    
  }
}

struct ThumbnailView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
