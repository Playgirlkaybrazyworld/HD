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
  @Binding private var topPost: Int?
  @StateObject private var viewModel = ThreadViewModel()
  @StateObject private var prefetcher = ThreadViewPrefetcher()
  
  init(title: String, board: String, threadNo: Int, topPost: Binding<Int?>) {
    self.title = title
    self.board = board
    self.threadNo = threadNo
    self._topPost = topPost
  }

  var body: some View {
    ScrollViewReader{ scrollViewProxy in
      posts
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
      .introspect(selector: TargetViewSelector.ancestorOrSiblingContaining) { (collectionView: UICollectionView) in
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self.prefetcher
      }
      .onChange(of: viewModel.scrollToPostNo) { postNo in
        if let postNo {
          scrollViewProxy.scrollTo(postNo)
          viewModel.scrollToPostNoAnimated = false
          viewModel.scrollToPostNo = nil
        }
      }
      .onChange(of: viewModel.topVisiblePost) {topVisiblePost in
        topPost = topVisiblePost
      }
    }
    .environment(\.openURL, OpenURLAction { url in
      if let postURL = PostURL(url:url) {
        viewModel.scrollToPostNo = postURL.postNo
        viewModel.scrollToPostNoAnimated = true
        return .handled
      }
      return .systemAction
    })
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
  var posts: some View {
    switch viewModel.threadState {
    case .loading:
      Text("Loading...")
    case let .display(posts):
      List(posts){post in
        PostView(board:board,
                 threadNo:threadNo,
                 post:post)
        .tag(post.id)
        .onAppear() {
          viewModel.appeared(post:post.id)
        }
        .onDisappear() {
          viewModel.disappeared(post:post.id)
        }
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
        if case .loading = viewModel.threadState {
          if let topPost {
            viewModel.scrollToPostNo = topPost
            viewModel.scrollToPostNoAnimated = true
          }
        }
        viewModel.threadState = .display(posts:posts)
        viewModel.threadState = .display(posts:posts)
      }
    } catch {
      viewModel.threadState = .error(error:error)
    }
  }
}
