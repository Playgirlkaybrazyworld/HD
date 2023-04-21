import Blackbird
import FourChan
import Introspect
import Network
import SwiftUI
import UIKit

struct ThreadView: View {
  @SceneStorage("thread_search") private var searchText = ""
  let title: String
  let board: String
  let threadNo: Int
  
  var body: some View {
    FilteredThreadView(title: title,
                       board: board,
                       threadNo: threadNo,
                       searchText:searchText)
      .searchable(text: $searchText)
  }
}

struct FilteredThreadView: View {
  @Environment(\.loader) private var loader: Loader!
  @EnvironmentObject private var client: Client
  
  let title: String
  let board: String
  let threadNo: Int
    
  /// The `posts` property is automatically updated when the database changes
  @BlackbirdLiveModels<Post> var posts : Blackbird.LiveResults<Post>
  
  @StateObject private var prefetcher = ThreadViewPrefetcher()
  @StateObject private var viewModel: ThreadViewModel
  
  init(title: String, board: String, threadNo: Int, searchText: String) {
    self.title = title
    self.board = board
    self.threadNo = threadNo
    _viewModel = StateObject(wrappedValue: ThreadViewModel(threadId:threadNo))
    
    _posts = .init({
      try await Post.read(
        from: $0
//        ,
//        matching: searchText.isEmpty ? \.$threadNo == threadNo :
//          (\.$threadNo == threadNo &&
//          (.like(\.$sub, "%\(searchText)%") ||
//            .like(\.$com, "%\(searchText)%")))
      )
    })
  }
  
  var body: some View {
    ScrollViewReader{ scrollViewProxy in
      postsView
        .refreshable {
          await refresh()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .introspect(selector: TargetViewSelector.ancestorOrSiblingContaining) { (collectionView: UICollectionView) in
          collectionView.isPrefetchingEnabled = true
          collectionView.prefetchDataSource = self.prefetcher
        }
        .onAppear {
          maybeScrollToPostNo(scrollViewProxy: scrollViewProxy)
        }
        .onChange(of: viewModel.scrollToPostNo) { _ in
          maybeScrollToPostNo(scrollViewProxy: scrollViewProxy)
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
        print("Could not refresh thread: \(error.localizedDescription)")
      }
    }
  }
  
  @ViewBuilder
  var postsView: some View {
    if posts.didLoad {
      List(posts.results){post in
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
    }
  }
  
  func refresh() async {
    do {
      try await loader.load(endpoint:.thread(board:board, no:threadNo))
      // self.prefetcher.posts = posts
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func maybeScrollToPostNo(scrollViewProxy: ScrollViewProxy) {
    if let postNo = viewModel.scrollToPostNo {
      scrollViewProxy.scrollTo(postNo)
      viewModel.scrollToPostNoAnimated = false
      viewModel.scrollToPostNo = nil
    }
  }
}
