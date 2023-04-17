import Introspect
import FourChan
import Network
import SwiftUI
import UIKit

struct ThreadView: View {
  let title: String
  let board: String
  let threadNo: Int
  @Binding private var topPost: Int?

  @SceneStorage("thread_search") private var searchText = ""
  
  init(title: String, board: String, threadNo: Int, topPost: Binding<Int?>) {
    self.title = title
    self.board = board
    self.threadNo = threadNo
    self._topPost = topPost
  }

  var body: some View {
    FilteredThreadView(title:title, board:board, threadNo: threadNo, topPost: _topPost, searchText:searchText)
    .searchable(text: $searchText)
  }
}

struct FilteredThreadView: View {
  @EnvironmentObject private var client: Client
  let title: String
  let board: String
  let threadNo: Int
  @Binding private var topPost: Int?
  let searchText: String
  @StateObject private var viewModel = ThreadViewModel()
  @StateObject private var prefetcher = ThreadViewPrefetcher()

  init(title: String, board: String, threadNo: Int, topPost: Binding<Int?>, searchText: String) {
    self.title = title
    self.board = board
    self.threadNo = threadNo
    self._topPost = topPost
    self.searchText = searchText
  }

  var body: some View {
    ScrollViewReader{ scrollViewProxy in
      posts
      .refreshable {
        await refresh()
      }
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
        print("Could not refresh thread: \(error.localizedDescription)")
      }
    }
  }
  
  @ViewBuilder
  var posts: some View {
    switch viewModel.threadState {
    case .loading:
      Text("Loading...")
    case let .display(posts):
      let filteredPosts = filter(posts:posts)
      if filteredPosts.isEmpty {
        Text("No posts match search text.")
      }
      List(filteredPosts){post in
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
      let fourChanPosts = thread?.posts ?? []
      let posts: [Post] = fourChanPosts.map {
        Post(
          id: $0.id,
          catalogThreadId: 0, // Filled in later
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
      print(error.localizedDescription)
      if case .display(_) = viewModel.threadState {
        // do nothing
      } else {
        viewModel.threadState = .error(error: error)
      }
    }
  }
  
  func filter(posts: [Post]) -> [Post] {
    if searchText.isEmpty {
      return posts
    } else {
      return posts.filter {
        $0.contains(text:searchText)
      }
    }
  }
}
