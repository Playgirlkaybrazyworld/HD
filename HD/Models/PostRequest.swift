import Combine
import GRDB
import GRDBQuery

/// A post request can be used with the `@Query` property wrapper in order to
/// feed a view with a list of posts.
///
/// For example:
///
///     struct MyView: View {
///         @Query(PostRequest(threadId: threadId)) private var posts: [Post]
///
///         var body: some View {
///             List(posts) { thread in ... )
///         }
///     }
struct PostRequest: Queryable {
  
  /// The ordering used by the player request.
  var threadId: Int
  
  // MARK: - Queryable Implementation
  
  static var defaultValue: [Post] { [] }
  
  func publisher(in appDatabase: AppDatabase) -> AnyPublisher<[Post], Error> {
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
  func fetchValue(_ db: Database) throws -> [Post] {
    return try Post.all().filter(threadId:threadId).fetchAll(db)
  }
}
