//
//  ThreadView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Introspect
import Models
import Network
import SwiftUI
import UIKit

struct ThreadView: View {
  @EnvironmentObject private var client: Client
  let board: String
  let threadNo: Int
  @State private var posts: Posts = []
  
  @StateObject private var prefetcher = ThreadViewPrefetcher()
  
  var body: some View {
    List(posts){post in
      PostView(board:board, post:post)
    }
    .navigationBarTitleDisplayMode(.inline)
    .listStyle(.plain)
    .introspect(selector: TargetViewSelector.ancestorOrSiblingContaining) { (collectionView: UICollectionView) in
      collectionView.isPrefetchingEnabled = true
      collectionView.prefetchDataSource = self.prefetcher
    }
    .onAppear {
      Task {
        self.prefetcher.board = board
        self.prefetcher.client = client
        while !Task.isCancelled {
          let thread: ChanThread = try await client.get(endpoint: .thread(board:board, no:threadNo))
          self.prefetcher.posts = thread.posts
          withAnimation {
            self.posts = thread.posts
          }
          try await Task.sleep(nanoseconds:30 * 1_000_000_000)
        }
      }
    }
  }
}

struct ThreadView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
