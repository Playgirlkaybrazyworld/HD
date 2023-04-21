import Blackbird

/// Remember information about the thread
struct ThreadMemo: BlackbirdModel {
  @BlackbirdColumn var id: Int
  /// The top post the last time the thread was read.
  @BlackbirdColumn var topPost: Int
}
