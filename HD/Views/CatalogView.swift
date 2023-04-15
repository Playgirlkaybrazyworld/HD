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
  @StateObject private var viewModel = CatalogViewModel()
  @SceneStorage("catalog_search") private var searchText = ""
  
  @StateObject private var prefetcher = CatalogViewPrefetcher()
  
  @Binding var selection: ThreadSelection?
  
  var body: some View {
    threads
    .refreshable {
      await refresh()
    }
    .searchable(text: $searchText)
    .onChange(of: searchText) {_ in
      selection = nil
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
  var threads : some View {
    switch viewModel.catalogState {
    case .loading:
      EmptyView()
    case let .display(threads):
      let filteredThreads = filter(threads:threads)
      if filteredThreads.isEmpty {
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
    case let .error(error):
      Text("Error: \(error.localizedDescription)")
    }
  }
  
  func refresh() async {
    var threads:[Post] = []
    do {
      let catalog: Catalog = try await client.get(endpoint: .catalog(board:board))
      threads = catalog.flatMap(\.threads)
    } catch {
      print(error.localizedDescription)
      if case .display(_) = viewModel.catalogState {
        // do nothing
      } else {
        viewModel.catalogState = .error(error: error)
      }
    }
    self.prefetcher.posts = threads
    withAnimation {
      viewModel.catalogState = .display(threads: threads)
    }
  }
  
  func filter(threads: [Post]) -> [Post] {
    if searchText.isEmpty {
      return threads
    } else {
      return threads.filter {
        $0.contains(text:searchText)
      }
    }
  }
}
