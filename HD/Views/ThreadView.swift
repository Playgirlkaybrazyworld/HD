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
  let thread: Post
  @State private var posts: Posts = []
  
  @StateObject private var prefetcher = ThreadViewPrefetcher()
  
  var body: some View {
    List(posts){post in
      PostView(board:board, post:post)
    }
    .introspect(selector: TargetViewSelector.ancestorOrSiblingContaining) { (collectionView: UICollectionView) in
      collectionView.isPrefetchingEnabled = true
      collectionView.prefetchDataSource = self.prefetcher
    }
    .onAppear {
      Task {
        let thread: ChanThread = try await client.get(endpoint: .thread(board:board, no:thread.no))
        withAnimation {
          self.posts = thread.posts
          self.prefetcher.posts = thread.posts
          self.prefetcher.board = board
          self.prefetcher.client = client
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
