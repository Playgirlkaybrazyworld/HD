import Blackbird

/// A singleton that contains the app state.
struct AppConfiguration: BlackbirdModel {
  @BlackbirdColumn var id: Int
  @BlackbirdColumn var boardId: String?
  @BlackbirdColumn var threadId: Int?
}
