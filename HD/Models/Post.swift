import Blackbird

struct Post: BlackbirdModel, Identifiable  {
  @BlackbirdColumn var id: Int
  /// Not part of FourChan Post
  @BlackbirdColumn var threadId: Int
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
