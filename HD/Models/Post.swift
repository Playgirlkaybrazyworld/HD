import GRDB

struct Post  {
  var id: Int
  /// Not part of FourChan Post
  var threadId: Int
  var sub: String?
  var com: String?
  var tim: Int?
  var filename: String?
  /// File extension. .jpg, .png, .gif, .pdf, .swf, .webm
  var ext: String?
  /// Image width.
  var w: Int?

  /// Image height.
  var h: Int?

  /// Thumbnail width.
  var tn_w: Int?

  /// Thumbnail height.
  var tn_h: Int?
  var replies: Int?
  var images: Int?
}

extension Post {
  var no: Int {
    id
  }
}

extension Post : Identifiable {}

// MARK: - Persistence

/// Make Post a Codable Record.
///
/// See <https://github.com/groue/GRDB.swift/blob/master/README.md#records>
extension Post: Codable, FetchableRecord, MutablePersistableRecord {
  // Define database columns from CodingKeys
  fileprivate enum Columns {
    static let id = Column(CodingKeys.id)
    static let threadId = Column(CodingKeys.threadId)
    static let sub = Column(CodingKeys.sub)
    static let com = Column(CodingKeys.com)
    static let tim = Column(CodingKeys.tim)
    static let filename = Column(CodingKeys.filename)
    static let ext = Column(CodingKeys.ext)
    static let w = Column(CodingKeys.w)
    static let h = Column(CodingKeys.h)
    static let tn_w = Column(CodingKeys.tn_w)
    static let tn_h = Column(CodingKeys.tn_h)
    static let replies = Column(CodingKeys.replies)
    static let images = Column(CodingKeys.images)
  }
}

extension Post: TableRecord {
  static let thread = belongsTo(CatalogThread.self)
  var thread: QueryInterfaceRequest<CatalogThread> {
    request(for: Post.thread)
  }
}

// MARK: - Post Database Requests

/// Define some post requests used by the application.
///
/// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/recordrecommendedpractices>
extension DerivableRequest<Post> {
  /// A request of posts for a given board ordered by id.
  ///
  /// For example:
  ///
  ///     let posts: [Post] = try dbWriter.read { db in
  ///         try Post.all().filter(threadId: threadId).fetchAll(db)
  ///     }
  func filter(threadId: Int) -> Self {
    filter(sql: "threadId = ?", arguments: [threadId]).orderByPrimaryKey()
  }
  
//  func threads(boardId: String) -> Self {
//    joining(required: CatalogThread.posts.filter(boardId:boardId))
//  }

}
