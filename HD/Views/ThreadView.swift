import Introspect
import FourChan
import Network
import SwiftUI
import UIKit

struct ThreadView: View {
  @EnvironmentObject private var client: Client
  let title: String
  let board: String
  let threadNo: Int
  @StateObject private var viewModel = ThreadViewModel()
  @StateObject private var prefetcher = ThreadViewPrefetcher()
  
  var body: some View {
    threads
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
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
      do {
        self.prefetcher.board = board
        self.prefetcher.client = client
        while !Task.isCancelled {
          await refresh()
          try await Task.sleep(nanoseconds:30 * 1_000_000_000)
        }
      } catch {
      }
    }
  }
  
  @ViewBuilder
  var threads: some View {
    switch viewModel.threadState {
    case .loading:
      Text("Loading...")
    case let .display(posts):
      List(posts){post in
        PostView(board:board,
                 threadNo:threadNo,
                 post:post)
        .listRowInsets(EdgeInsets())
      }
      .listStyle(.plain)
    case let .error(error):
      Text("Error: \(error.localizedDescription)")
    }
  }
  
  func refresh() async {
    do {
      let thread: ChanThread? = try await client.get(endpoint: .thread(board:board, no:threadNo))
      let posts = thread?.posts ?? []
      self.prefetcher.posts = posts
      withAnimation {
        viewModel.threadState = .display(posts:posts)
      }
    } catch {
      viewModel.threadState = .error(error:error)
    }
  }
}

struct ThreadView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
