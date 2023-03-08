//
//  ImageView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Network
import SwiftUI

struct ImageView: View {
  @EnvironmentObject private var client: Client
  @Environment(\.displayScale) private var displayScale: CGFloat
  let board: String
  let tim: Int
  let ext: String
  var body: some View {
    AsyncImage(url:client.makeURL(endpoint:.image(board: board, tim: tim, ext: ext)), scale:displayScale)
  }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        Text("TBD")
    }
}
