import Combine
import GRDB
import GRDBQuery

/// A board request can be used with the `@Query` property wrapper in order to
/// feed a view with a list of boards.
///
/// For example:
///
///     struct MyView: View {
///         @Query(BoardRequest(ordering: .byID)) private var boards: [Board]
///
///         var body: some View {
///             List(boards) { board in ... )
///         }
///     }
struct BoardRequest: Queryable {
  
  /// If non-empty, used in a "Like" query
  var like: String
  
  // MARK: - Queryable Implementation
  
  static var defaultValue: [Board] { [] }
  
  func publisher(in appDatabase: AppDatabase) -> AnyPublisher<[Board], Error> {
    // Build the publisher from the general-purpose read-only access
    // granted by `appDatabase.reader`.
    // Some apps will prefer to call a dedicated method of `appDatabase`.
    ValueObservation
      .tracking(fetchValue(_:))
      .publisher(
        in: appDatabase.reader,
        // The `.immediate` scheduling feeds the view right on
        // subscription, and avoids an undesired animation when the
        // application starts.
        scheduling: .immediate)
      .eraseToAnyPublisher()
  }
  
  // This method is not required by Queryable, but it makes it easier
  // to test PlayerRequest.
  func fetchValue(_ db: Database) throws -> [Board] {
    if like.isEmpty {
      return try Board.all().orderedByName().fetchAll(db)
    } else {
      let like = "%\(like)%"
      return try Board.all()
        .filter(sql: "name LIKE ? OR title LIKE ?", arguments: [like, like])
        .orderedByName().fetchAll(db)
    }
  }
}
