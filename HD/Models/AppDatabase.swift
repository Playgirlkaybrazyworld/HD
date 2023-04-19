import Foundation
import GRDB
import os.log

/// A database of posts.
///
/// You create an `AppDatabase` with a connection to an SQLite database
/// (see <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>).
///
/// Create those connections with a configuration returned from
/// `AppDatabase/makeConfiguration(_:)`.
///
/// For example:
///
/// ```swift
/// // Create an in-memory AppDatabase
/// let config = AppDatabase.makeConfiguration()
/// let dbQueue = try DatabaseQueue(configuration: config)
/// let appDatabase = try AppDatabase(dbQueue)
/// ```
struct AppDatabase {
  /// Creates an `AppDatabase`, and makes sure the database schema
  /// is ready.
  ///
  /// - important: Create the `DatabaseWriter` with a configuration
  ///   returned by ``makeConfiguration(_:)``.
  init(_ dbWriter: any DatabaseWriter) throws {
    self.dbWriter = dbWriter
    try migrator.migrate(dbWriter)
  }
  
  /// Provides access to the database.
  ///
  /// Application can use a `DatabasePool`, while SwiftUI previews and tests
  /// can use a fast in-memory `DatabaseQueue`.
  ///
  /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>
  private let dbWriter: any DatabaseWriter
}

// MARK: - Database Configuration

extension AppDatabase {
  private static let sqlLogger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "SQL")
  
  /// Returns a database configuration suited for `PlayerRepository`.
  ///
  /// SQL statements are logged if the `SQL_TRACE` environment variable
  /// is set.
  ///
  /// - parameter base: A base configuration.
  public static func makeConfiguration(_ base: Configuration = Configuration()) -> Configuration {
    var config = base
    
    // An opportunity to add required custom SQL functions or
    // collations, if needed:
    // config.prepareDatabase { db in
    //     db.add(function: ...)
    // }
    
//    config.prepareDatabase { db in
//        db.trace { print("SQL: \($0)") }
//    }

    // Log SQL statements if the `SQL_TRACE` environment variable is set.
    // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/database/trace(options:_:)>
    if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
      config.prepareDatabase { db in
        db.trace {
          // It's ok to log statements publicly. Sensitive
          // information (statement arguments) are not logged
          // unless config.publicStatementArguments is set
          // (see below).
          os_log("%{public}@", log: sqlLogger, type: .debug, String(describing: $0))
        }
      }
    }
    
#if DEBUG
    // Protect sensitive information by enabling verbose debugging in
    // DEBUG builds only.
    // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/configuration/publicstatementarguments>
    config.publicStatementArguments = true
#endif
    
    return config
  }
}

// MARK: - Database Migrations

extension AppDatabase {
  /// The DatabaseMigrator that defines the database schema.
  ///
  /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
  private var migrator: DatabaseMigrator {
    var migrator = DatabaseMigrator()
    
#if DEBUG
    // Speed up development by nuking the database when migrations change
    // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
    migrator.eraseDatabaseOnSchemaChange = true
#endif
    
    migrator.registerMigration("createDB") { db in
      // Create a table
      // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseschema>
      try db.create(table: "board") { t in
        t.column("name", .text).primaryKey().notNull()
        t.column("title", .integer).notNull()
      }
      
      try db.create(table: "thread") { t in
        t.column("threadno", .integer).primaryKey().notNull()
        t.column("boardId", .text)
          .notNull()
          .indexed()
          .references("board", onDelete: .cascade)
      }
      
      try db.create(table: "post") { t in
        t.column("id", .integer).primaryKey().notNull()
        t.column("threadId", .integer).notNull()
          .indexed()
          .references("thread", onDelete: .cascade)
        t.column("sub", .text)
        t.column("com", .text)
        t.column("tim", .integer)
        t.column("filename", .text)
        t.column("ext", .text)
        t.column("w", .integer)
        t.column("h", .integer)
        t.column("tn_w", .integer)
        t.column("tn_h", .integer)
        t.column("replies", .integer)
        t.column("images", .integer)
      }
      
      try db.create(table: "threadMemo") { t in
        t.column("threadId", .integer).primaryKey().notNull()
          .references("thread", onDelete: .cascade)
        t.column("topPost", .integer)
          .notNull()
          .indexed()
          .references("post", onDelete: .cascade)
      }
      
      try db.create(table: "appConfiguration") { t in
        // The single row guarantee
        t.primaryKey("id", .integer, onConflict: .replace).check { $0 == 1 }
      
        // The configuration columns
        t.column("boardID", .text)
          .indexed()
          .references("board", onDelete: .setNull)
        t.column("threadID", .integer)
          .indexed()
          .references("thread", onDelete: .setNull)
      }
    }
    
    // Migrations for future application versions will be inserted here:
    // migrator.registerMigration(...) { db in
    //     ...
    // }
    
    return migrator
  }
}

// MARK: - Database Access: Writes
// The write methods execute invariant-preserving database transactions.

extension AppDatabase {
  
  func updateSelection(boardId: String? = nil, threadId: Int? = nil) async throws {
    // If boardId is nil, then threadId is also nil.
    let threadId = boardId == nil ? nil : threadId
    try await dbWriter.write { db in
      var config = try AppConfiguration.fetch(db)
      try config.updateChanges(db) {
        $0.boardId = boardId
        $0.threadId = threadId
      }
    }
  }
  
  func update(boards: [Board]) async throws  {
    try await dbWriter.write { db in
      // Find obsolete boards
      let newBoardNames = Set(boards.map(\.name))
      let oldBoards = try Board.all().fetchAll(db)
      let deadBoards = oldBoards.filter{ !newBoardNames.contains($0.name)}
      if !deadBoards.isEmpty {
        // Remove all old rows.
        let deadBoardIDs = deadBoards.map(\.id)
        _ = try Board.deleteAll(db,ids:deadBoardIDs)
      }
      
      // Add/update all new rows.
      for var board in boards {
        try board.upsert(db)
      }
    }
  }
  
  func update(boardId: String, threads: [Post]) async throws {
    try await dbWriter.write { db in
      // Delete obsolete threads
      let newThreadIDs = Set(threads.map(\.id))
      let oldThreads = try CatalogThread.all().filter(boardId: boardId).fetchAll(db)
      let deadThreads = oldThreads.filter{ !newThreadIDs.contains($0.id)}
      if !deadThreads.isEmpty {
        // Remove all old rows.
        let deadThreadIDs = deadThreads.map(\.id)
        _ = try CatalogThread.deleteAll(db, ids:deadThreadIDs)
      }
      
      // Add CatalogThreads and posts
      for var thread in threads {
        var catalogThread = CatalogThread(threadNo: thread.id, boardId: boardId)
        try catalogThread.upsert(db)
        thread.threadId = catalogThread.threadNo
        try thread.upsert(db)
      }
    }
  }
  
  func update(posts: [Post]) async throws {
    try await dbWriter.write { db in
      // Append-only API, don't delete any old posts.
      
      // Add posts
      for var post in posts {
        try post.upsert(db)
      }
    }
  }
  
  func saveTopPost(threadId: Int, topPost: Int) async throws {
    try await dbWriter.write { db in
      var memo = try? ThreadMemo.fetchOne(db, id:threadId)
      if memo != nil {
        memo!.topPost = topPost
      } else {
        memo = ThreadMemo(threadId:threadId, topPost: topPost)
      }
      try memo!.save(db)
    }
  }
  
  private static let uiTestBoards = [
    Board(name: "3", title: "3DCG"),
    Board(name: "a", title: "Anime & Manga")]
  
  func createBoardsForUITests() throws {
    try dbWriter.write { db in
      try AppDatabase.uiTestBoards.forEach { board in
        _ = try board.inserted(db) // insert but ignore inserted id
      }
    }
  }
}

// MARK: - Database Access: Reads

// This demo app does not provide any specific reading method, and instead
// gives an unrestricted read-only access to the rest of the application.
// In your app, you are free to choose another path, and define focused
// reading methods.
extension AppDatabase {
  /// Provides a read-only access to the database
  var reader: DatabaseReader {
    dbWriter
  }
}
