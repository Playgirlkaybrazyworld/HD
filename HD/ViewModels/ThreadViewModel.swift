import Foundation

typealias PostNumber = Int

class ThreadViewModel : ObservableObject {
  @Published var scrollToPostNo: PostNumber?
  @Published var threadState: ThreadState = .loading
  @Published var topVisiblePost: PostNumber?
    
  var visiblePosts = Set<PostNumber>()
  var scrollToPostNoAnimated: Bool = false
  
  func appeared(post: PostNumber) {
    visiblePosts.insert(post)
    topVisiblePost = computeTopVisiblePost()
  }
  
  func disappeared(post: PostNumber) {
    visiblePosts.remove(post)
    topVisiblePost = computeTopVisiblePost()
  }
  
  func computeTopVisiblePost() -> PostNumber? {
    visiblePosts.sorted().first
  }
  
  func index(postNo:PostNumber)->Int? {
    if case let .display(posts) = threadState {
      return posts.firstIndex{ $0.id == postNo }
    }
    return nil
  }
}

enum ThreadState {
  case loading
  case display(posts: [Post])
  case error(error: Error)
}
