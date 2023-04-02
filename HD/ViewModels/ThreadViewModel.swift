import Foundation
import FourChan

class ThreadViewModel : ObservableObject {
  @Published var scrollToPostNo: PostNumber?
  @Published var threadState: ThreadState = .loading
  
  var visiblePosts = Set<PostNumber>()
  var scrollToPostNoAnimated: Bool = false
  
  func appeared(post: PostNumber) {
    visiblePosts.insert(post)
  }
  
  func disappeared(post: PostNumber) {
    visiblePosts.remove(post)
  }
  
  var topVisiblePost: PostNumber? {
    visiblePosts.sorted().first
  }
  
  func index(postNo:PostNumber)->Int? {
    if case let .display(posts) = threadState {
      return posts.firstIndex{ $0.id == postNo }
    }
    return nil
  }
}

public enum ThreadState {
  case loading
  case display(posts: [Post])
  case error(error: Error)
}
