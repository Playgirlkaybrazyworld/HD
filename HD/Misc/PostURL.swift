import Foundation
import FourChan

struct PostURL {
  var postNo: PostNumber
  
  init?(url: URL) {
    if url.scheme != nil || url.host != nil || !url.pathComponents.isEmpty {
      return nil
    }
    guard let fragment = url.fragment else { return nil }
    if !fragment.hasPrefix("p") {
      return nil
    }
    guard let postNo = Int(fragment.dropFirst()),
      postNo >= 0
    else {
      return nil
    }
    self.postNo = postNo
  }
}
