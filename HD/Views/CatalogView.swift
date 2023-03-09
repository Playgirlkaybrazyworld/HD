//
//  BoardView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Introspect
import Models
import Network
import SwiftUI
import UIKit

struct CatalogView: View {
  @EnvironmentObject private var client: Client
  let board: Board
  @State private var threads: Posts = []
  
  @StateObject private var prefetcher = CatalogViewPrefetcher()

  var body: some View {
    List(threads){ thread in
      NavigationLink {
        ThreadView(board:board.id, thread:thread)
      } label: {
        CatalogRowView(board:board.id, thread: thread)
      }
    }
    .navigationTitle(board.title)
    .navigationBarTitleDisplayMode(.inline)
    .introspect(selector: TargetViewSelector.ancestorOrSiblingContaining) { (collectionView: UICollectionView) in
      collectionView.isPrefetchingEnabled = true
      collectionView.prefetchDataSource = self.prefetcher
    }
    .onAppear {
      Task {
        let catalog: Catalog = try await client.get(endpoint: .catalog(board:board.id))
        let threads = catalog.flatMap(\.threads)
        self.prefetcher.posts = threads
        self.prefetcher.board = board.id
        self.prefetcher.client = client
        withAnimation {
          self.threads = threads
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
