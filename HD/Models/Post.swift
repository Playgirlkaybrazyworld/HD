import Blackbird

struct Post : BlackbirdModel {
  @BlackbirdColumn var id: Int
  /// The board this post is in. Note that this is not part of the FourChan Post.
  @BlackbirdColumn var board: String
  @BlackbirdColumn var sub: String?
  @BlackbirdColumn var com: String?
  @BlackbirdColumn var tim: Int?
  @BlackbirdColumn var filename: String?
  /// File extension. .jpg, .png, .gif, .pdf, .swf, .webm
  @BlackbirdColumn var ext: String?
  /// Image width.
  @BlackbirdColumn var w: Int?

  /// Image height.
  @BlackbirdColumn var h: Int?

  /// Thumbnail width.
  @BlackbirdColumn var tn_w: Int?

  /// Thumbnail height.
  @BlackbirdColumn var tn_h: Int?
  @BlackbirdColumn var replies: Int?
  @BlackbirdColumn var images: Int?
}

extension Post {
  var no: Int {
    id
  }
}
