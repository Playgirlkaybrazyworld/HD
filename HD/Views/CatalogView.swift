//
//  BoardView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Env
import FourChan
import Introspect
import Network
import SwiftUI
import UIKit

struct ThreadSelection: Codable, Hashable {
  let board : String
  let title: String
  let no: Int
}

struct CatalogView: View {
  @EnvironmentObject private var client: Client

  let board: String
  let title: String
  @State private var threads: Posts = []
  @State private var loading: Bool = true
  @SceneStorage("catalog_search") private var searchText = ""

  @StateObject private var prefetcher = CatalogViewPrefetcher()

  @Binding var selection: ThreadSelection?

  var body: some View {
    let filteredThreads = filteredThreads
    if !loading && filteredThreads.isEmpty {
      Text("No threads match search text.")
    }
    List(filteredThreads, id:\.id, selection: $selection){ thread in
      CatalogRowView(board:board, thread: thread)
        .tag(ThreadSelection(
          board: board,
          title: thread.title,
          no: thread.no
        ))
    }
    .refreshable {
      await refresh()
    }
    .searchable(text: $searchText)
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .listStyle(.plain)
    .introspect(selector: TargetViewSelector.ancestorOrSiblingContaining) { (collectionView: UICollectionView) in
      collectionView.isPrefetchingEnabled = true
      collectionView.prefetchDataSource = self.prefetcher
    }
    .introspectNavigationController { navigationController in
      navigationController.hidesBarsOnSwipe = true
    }
    // Ideally we would only hide this when swiping.
    .statusBar(hidden: true)
    .onAppear {
      Task {
        self.prefetcher.board = board
        self.prefetcher.client = client
        await refresh()
      }
    }
  }
  
  func refresh() async {
    loading = true
    var threads:[Post] = []
    do {
      let catalog: Catalog = try await client.get(endpoint: .catalog(board:board))
      threads = catalog.flatMap(\.threads)
    } catch {
      print("Error loading \(board): \(error)")
    }
    self.prefetcher.posts = threads
    withAnimation {
      loading = false
      self.threads = threads
    }
  }
  
  var filteredThreads: [Post] {
      if searchText.isEmpty {
          return threads
      } else {
        return threads.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
      }
  }
}

struct BoardView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
