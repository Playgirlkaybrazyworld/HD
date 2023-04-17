import Foundation

typealias PostNumber = Int

class ThreadViewModel : ObservableObject {
  @Published var scrollToPostNo: PostNumber?
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
}
