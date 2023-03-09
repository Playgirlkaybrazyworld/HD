//
//  BoardView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Models
import Network
import SwiftUI

struct CatalogView: View {
  @EnvironmentObject private var client: Client
  let board: Board
  @State private var threads: Posts = []
  var body: some View {
    List(threads){ thread in
      NavigationLink {
        ThreadView(board:board.id, thread:thread)
      } label: {
        CatalogRowView(thread: thread)
      }
    }
    .navigationTitle(board.title)
    .onAppear {
      Task {
        let catalog: Catalog = try await client.get(endpoint: .catalog(board:board.id))
        withAnimation {
          self.threads = catalog.flatMap(\.threads)
        }
      }
    }
  }
}

struct BoardView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
