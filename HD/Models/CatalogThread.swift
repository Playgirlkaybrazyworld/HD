import GRDB

struct CatalogThread {
  static let databaseTableName = "thread"

  var threadNo: Int
  var boardId: String
}

extension CatalogThread: Identifiable {
  var id: Int {
    threadNo
  }
}

// MARK: - Persistence

/// Make Board a Codable Record.
///
/// See <https://github.com/groue/GRDB.swift/blob/master/README.md#records>
extension CatalogThread: Codable, FetchableRecord, MutablePersistableRecord {
  // Define database columns from CodingKeys
  fileprivate enum Columns {
    static let threadNo = Column(CodingKeys.threadNo)
    static let boardId = Column(CodingKeys.boardId)
  }
}

extension CatalogThread: TableRecord {
  static let board = belongsTo(Board.self)
  var board: QueryInterfaceRequest<Board> {
    request(for: CatalogThread.board)
  }
  
  static let posts = hasMany(Post.self)
  var posts: QueryInterfaceRequest<Post> {
    request(for: CatalogThread.posts)
  }
}


// MARK: - Board Database Requests

/// Define some board requests used by the application.
///
/// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/recordrecommendedpractices>
extension DerivableRequest<CatalogThread> {
  /// A request of threads for a given boardId.
  ///
  /// For example:
  ///
  ///     let catalogThreads: [CatalogThread] = try dbWriter.read { db in
  ///         try CatalogThread.all().filter(boardId:boardId).fetchAll(db)
  ///     }
  func filter(boardId:String) -> Self {
    // See https://github.com/groue/GRDB.swift/blob/master/README.md#string-comparison
    filter(sql: "boardId = ?", arguments:[boardId])
  }
}
