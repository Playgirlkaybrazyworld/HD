import Foundation

typealias PostNumber = Int

class ThreadViewModel : ObservableObject {
  var appDatabase: AppDatabase
  let threadId: Int
  
  @Published var scrollToPostNo: PostNumber?
  @Published var topVisiblePost: PostNumber?
    
  private var visiblePosts = Set<PostNumber>()
  var scrollToPostNoAnimated: Bool = false
  
  init(appDatabase: AppDatabase, threadId: Int) {
    self.appDatabase = appDatabase
    self.threadId = threadId
    
    if let topPost = try? appDatabase.reader.read({ db in
      let memo = try ThreadMemo.fetchOne(db, id:threadId)
      return memo?.topPost
    }) {
      scrollToPostNo = topPost
    }
  }
  
  func appeared(post: PostNumber) {
    visiblePosts.insert(post)
    updateTopVisiblePost()
  }
  
  func updateTopVisiblePost() {
    let newTopVisiblePost = computeTopVisiblePost()
    if topVisiblePost != newTopVisiblePost {
      topVisiblePost = newTopVisiblePost
      if let topVisiblePost, scrollToPostNo == nil  {
        Task {
          try await appDatabase.saveTopPost(threadId: threadId, topPost:topVisiblePost)
        }
      }
    }
  }
  
  func disappeared(post: PostNumber) {
    visiblePosts.remove(post)
    updateTopVisiblePost()
  }
  
  private func computeTopVisiblePost() -> PostNumber? {
    visiblePosts.sorted().first
  }
}
