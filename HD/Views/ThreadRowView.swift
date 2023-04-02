import FourChan
import HTMLString
import SwiftUI

struct ThreadRowView: View {
  let post: Post
  var body: some View {
    Text("\(post.no) \(subject)")
  }
  
  var subject: String {
    if let sub = post.sub {
      return HTMLString(html: sub).asRawText
    }
    return ""
  }
}

struct ThreadRowView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
