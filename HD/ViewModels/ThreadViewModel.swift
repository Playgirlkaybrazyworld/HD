import Foundation
import FourChan

class ThreadViewModel : ObservableObject {
  @Published var scrollToPostNo: PostNumber?
  @Published var threadState: ThreadState = .loading

  var scrollToPostNoAnimated: Bool = false
}

public enum ThreadState {
  case loading
  case display(posts: [Post])
  case error(error: Error)
}
