import SwiftData

@Model
final class Post  {
  @Attribute(.unique)
  var no: Int
  /// Not part of FourChan Post
  var threadId: Int
  var sub: String?
  var com: String?
  var tim: Int?
  var filename: String?
  /// File extension. .jpg, .png, .gif, .pdf, .swf, .webm
  var ext: String?
  /// Image width.
  var w: Int?

  /// Image height.
  var h: Int?

  /// Thumbnail width.
  var tn_w: Int?

  /// Thumbnail height.
  var tn_h: Int?
  var replies: Int?
  var images: Int?
  
  init(no: Int,
       threadId: Int,
       sub: String? = nil,
       com: String? = nil,
       tim: Int? = nil,
       filename: String? = nil,
       ext: String? = nil,
       w: Int? = nil,
       h: Int? = nil,
       tn_w: Int? = nil,
       tn_h: Int? = nil,
       replies: Int? = nil,
       images: Int? = nil

  ) {
    self.no = no
    self.threadId = threadId
    self.sub = sub
    self.com = com
    self.tim = tim
    self.filename = filename
    self.ext = ext
    self.w = w
    self.h = h
    self.tn_w = tn_w
    self.tn_h = tn_h
    self.replies = replies
    self.images = images
  }
}

extension Post {
  static var preview: Post {
    let item = Post(
      no: 17,
      threadId: 17
    )
    return item
  }
}

