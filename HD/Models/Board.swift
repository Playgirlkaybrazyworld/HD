import GRDB

struct Board {
  var name: String
  var title: String
}

extension Board: Identifiable {
  var id: String {
    name
  }
}

// MARK: - Persistence

/// Make Board a Codable Record.
///
/// See <https://github.com/groue/GRDB.swift/blob/master/README.md#records>
extension Board: Codable, FetchableRecord, MutablePersistableRecord {
  // Define database columns from CodingKeys
  fileprivate enum Columns {
    static let name = Column(CodingKeys.name)
    static let title = Column(CodingKeys.title)
  }
}

extension Board: TableRecord {
    static let threads = hasMany(CatalogThread.self)
    var threads: QueryInterfaceRequest<CatalogThread> {
        request(for: Board.threads)
    }
}


// MARK: - Board Database Requests

/// Define some board requests used by the application.
///
/// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/recordrecommendedpractices>
extension DerivableRequest<Board> {
  /// A request of boards ordered by name.
  ///
  /// For example:
  ///
  ///     let boards: [Board] = try dbWriter.read { db in
  ///         try Board.all().orderedByName().fetchAll(db)
  ///     }
  func orderedByName() -> Self {
    // Sort by name in a localized case insensitive fashion
    // See https://github.com/groue/GRDB.swift/blob/master/README.md#string-comparison
    order(Board.Columns.name.collating(.localizedCaseInsensitiveCompare))
  }
}
