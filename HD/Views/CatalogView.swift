//
//  BoardView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Env
import Introspect
import Models
import Network
import SwiftUI
import UIKit

struct CatalogView: View {
  @EnvironmentObject private var client: Client
  let board: String
  @State private var threads: Posts = []
  
  @StateObject private var prefetcher = CatalogViewPrefetcher()
  let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

  var body: some View {
    List(threads){ thread in
      NavigationLink(value: RouterDestination.thread(board:board, threadNo:thread.no)) {
        CatalogRowView(board:board, thread: thread)
      }
    }
    .navigationTitle(board)
    .navigationBarTitleDisplayMode(.inline)
    .introspect(selector: TargetViewSelector.ancestorOrSiblingContaining) { (collectionView: UICollectionView) in
      collectionView.isPrefetchingEnabled = true
      collectionView.prefetchDataSource = self.prefetcher
    }
    .onAppear {
      Task {
        self.prefetcher.board = board
        self.prefetcher.client = client
        while !Task.isCancelled {
          let catalog: Catalog = try await client.get(endpoint: .catalog(board:board))
          let threads = catalog.flatMap(\.threads)
          self.prefetcher.posts = threads
          withAnimation {
            self.threads = threads
          }
          try await Task.sleep(nanoseconds:30 * 1_000_000_000)
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
