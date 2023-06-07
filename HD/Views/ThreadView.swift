import FourChan
import Introspect
import Network
import SwiftUI
import UIKit
import SwiftData

struct ThreadView: View {
  @EnvironmentObject private var client: Client
  let title: String
  let board: String
  let threadNo: Int
  
  @Environment(\.modelContext) private var modelContext

  /// The `threads` property is automatically updated when the database changes
  @Query private var posts: [Post]
  
  @StateObject private var prefetcher = ThreadViewPrefetcher()
//  private var viewModel: ThreadViewModel
  
  init(title: String, board: String, threadNo: Int) {
    self.title = title
    self.board = board
    self.threadNo = threadNo
//    viewModel =
//      ThreadViewModel(
//        appDatabase: env.appDatabase,
//                      threadId:threadNo)
//  }
    
  }
  
  var body: some View {
    ScrollViewReader{ scrollViewProxy in
      postsView
        // .searchable(text:$posts.like)
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
//        .onChange(of: viewModel.scrollToPostNo) {
//          maybeScrollToPostNo(scrollViewProxy: scrollViewProxy)
//        }
    }
//    .environment(\.openURL, OpenURLAction { url in
//      if let postURL = PostURL(url:url) {
////        viewModel.scrollToPostNo = postURL.postNo
////        viewModel.scrollToPostNoAnimated = true
//        return .handled
//      }
//      return .systemAction
//    })
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
    List(posts){post in
      PostView(board:board,
               threadNo:threadNo,
               post:post)
      .tag(post.no)
//      .onAppear() {
//        viewModel.appeared(post:post.id)
//      }
//      .onDisappear() {
//        viewModel.disappeared(post:post.id)
//      }
      .listRowInsets(EdgeInsets())
    }
    .listStyle(.plain)
  }
  
  func refresh() async {
    do {
      let thread: ChanThread? = try await client.get(endpoint: .thread(board:board, no:threadNo))
      let fourChanPosts = thread?.posts ?? []
      let posts: [Post] = fourChanPosts.map {
        Post(
          no: $0.id,
          threadId: threadNo,
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
      // TODO bulk insert
      for post in posts {
        modelContext.insert(post)
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func maybeScrollToPostNo(scrollViewProxy: ScrollViewProxy) {
//    if let postNo = viewModel.scrollToPostNo {
//      scrollViewProxy.scrollTo(postNo)
//      viewModel.scrollToPostNoAnimated = false
//      viewModel.scrollToPostNo = nil
//    }
  }
}
