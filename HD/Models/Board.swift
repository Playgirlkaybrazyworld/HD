import Blackbird

struct Board : BlackbirdModel {
  @BlackbirdColumn var id: String
  @BlackbirdColumn var title: String
}
