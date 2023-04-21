import FourChan
import Blackbird
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
  @SceneStorage("catalog_search") private var searchText = ""
  
  let board: String
  let title: String

  @Binding var selection: ThreadSelection?
  
  var body: some View {
    FilteredCatalogView(board:board, title:title, selection:_selection, searchText:searchText)
      .searchable(text: $searchText)
  }
}

struct FilteredCatalogView: View {
  @Environment(\.loader) private var loader: Loader!
  @EnvironmentObject private var client: Client

  let board: String
  let title: String
  @Binding var selection: ThreadSelection?
  
  /// The `threads` property is automatically updated when the database changes
  @BlackbirdLiveModels<Post> var threads : Blackbird.LiveResults<Post>

  @StateObject private var prefetcher = CatalogViewPrefetcher()
  
  
  init(board:String, title:String,
       selection: Binding<ThreadSelection?>, searchText: String) {
    self.board = board
    self.title = title
    _selection = selection
    _threads = .init({
      try await Post.read(
        from: $0,
        matching: FilteredCatalogView.matching(boardId: board, searchText:searchText)
      )
    })
  }
  
  static func matching(boardId: String, searchText:String) -> BlackbirdModelColumnExpression<Post> {
    if searchText.isEmpty {
      return \.$boardId == boardId && \.$isThread == true
    } else {
      return \.$boardId == boardId && \.$isThread == true &&
               (.like(\.$sub, "%\(searchText)%") ||
                 .like(\.$com, "%\(searchText)%"))
    }
  }
  
  var body: some View {
    threadsView
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
    if threads.didLoad {
      List(threads.results, id:\.id, selection: $selection){ thread in
        CatalogRowView(board:board, thread: thread)
          .tag(ThreadSelection(
            board: board,
            title: thread.title,
            no: thread.id
          ))
      }
    }
  }
  
  func refresh() async {
    do {
      try await loader.load(endpoint: .catalog(board:board))
    } catch {
      print(error.localizedDescription)
    }
  }
}
