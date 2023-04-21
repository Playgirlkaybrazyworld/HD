import Blackbird

struct Board: BlackbirdModel {
  /// The "name" of the board is the id.
  @BlackbirdColumn var id: String
  @BlackbirdColumn var title: String
}
