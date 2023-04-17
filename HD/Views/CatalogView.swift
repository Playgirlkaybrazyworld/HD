import FourChan
import GRDBQuery
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
  
  /// Write access to the database
  @Environment(\.appDatabase) private var appDatabase
  
  /// The `threads` property is automatically updated when the database changes
  @Query<CatalogThreadRequest> private var threads: [Post]

  @StateObject private var prefetcher = CatalogViewPrefetcher()
  
  @Binding var selection: ThreadSelection?
  
  init(board:String, title:String,
       selection: Binding<ThreadSelection?>) {
    self.board = board
    self.title = title
    _selection = selection
    _threads = .init(CatalogThreadRequest(boardId:board, like:""))
  }

  var body: some View {
    threadsView
      .searchable(text: $threads.like)
    .refreshable {
      await refresh()
    }
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
    .task {
      self.prefetcher.board = board
      self.prefetcher.client = client
      await refresh()
    }
  }
  
  @ViewBuilder
  var threadsView : some View {
    List(threads, id:\.id, selection: $selection){ thread in
      CatalogRowView(board:board, thread: thread)
        .tag(ThreadSelection(
          board: board,
          title: thread.title,
          no: thread.no
        ))
    }
  }
  
  func refresh() async {
    do {
      let catalog: Catalog = try await client.get(endpoint: .catalog(board:board))
      let fourChanThreads = catalog.flatMap(\.threads)
      let threads = fourChanThreads.map {
        Post(
          id: $0.id,
          catalogThreadId: $0.id,
          sub: $0.sub,
          com: $0.com,
          tim: $0.tim,
          filename: $0.filename,
          ext: $0.ext,
          w: $0.w,
          h: $0.h,
          tn_w: $0.tn_w,
          tn_h: $0.tn_h,
          replies: $0.replies,
          images: $0.images
        )
      }
      self.prefetcher.posts = threads
      try await appDatabase.update(boardId:board, threads:threads)
    } catch {
      print(error.localizedDescription)
    }
  }
}
