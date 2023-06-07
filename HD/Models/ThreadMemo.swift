import SwiftData

/// Remember information about the thread
@Model
final class ThreadMemo {
  @Attribute(.unique)
  var threadId: Int
  /// The top post the last time the thread was read.
  var topPost: Int

  init(threadId: Int, topPost: Int) {
    self.threadId = threadId
    self.topPost = topPost
  }
}

extension ThreadMemo {
  static var preview: ThreadMemo {
    let item = ThreadMemo(
      threadId: 17,
      topPost: 17
    )
    return item
  }
}
