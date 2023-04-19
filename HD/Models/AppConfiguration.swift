import GRDB

struct AppConfiguration: Codable {
    // Support for the single row guarantee
    private var id = 1
    
    // The configuration properties
  var boardId: String?
  var threadId: Int?
}

extension AppConfiguration {
    /// The default configuration
    static let `default` = AppConfiguration(boardId: nil, threadId: nil)
}

// Database Access
extension AppConfiguration: FetchableRecord, PersistableRecord {
    // Customize the default PersistableRecord behavior
    func willUpdate(_ db: Database, columns: Set<String>) throws {
        // Insert the default configuration if it does not exist yet.
        if try !exists(db) {
            try AppConfiguration.default.insert(db)
        }
    }
    
    /// Returns the persisted configuration, or the default one if the
    /// database table is empty.
    static func fetch(_ db: Database) throws -> AppConfiguration {
        try fetchOne(db) ?? .default
    }
}
