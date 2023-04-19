import GRDB

/// Remember information about the thread
struct ThreadMemo {
  var threadId: Int
  /// The top post the last time the thread was read.
  var topPost: Int
}

extension ThreadMemo: Identifiable {
  var id: Int {
    threadId
  }
}

/// Make ThreadMemo a Codable Record.
///
/// See <https://github.com/groue/GRDB.swift/blob/master/README.md#records>
extension ThreadMemo: Codable, FetchableRecord, MutablePersistableRecord {
  // Define database columns from CodingKeys
  fileprivate enum Columns {
    static let threadId = Column(CodingKeys.threadId)
    static let topPost = Column(CodingKeys.topPost)
  }
}
