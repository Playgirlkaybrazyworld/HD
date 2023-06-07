import FourChan
import HTMLString
import SwiftUI

struct PostView: View {
  let board: String
  let threadNo: Int
  let post: Post
  var body: some View {
    ScrollView {
      VStack(alignment:.leading, spacing: 0) {
        if hasImage {
          let (width, height, aspectRatio) = metrics
          image
            .invisibleWhenNotActive()
            // preserve aspect ratio
            .aspectRatio(aspectRatio, contentMode: .fill)
            // No larger than original size
            .frame(maxWidth:width, maxHeight:height)
            // Center within allocated space.
            .frame(
              maxWidth: .infinity,
              maxHeight: .infinity,
              alignment: .center
            )
        }
        if let com = post.com {
          Text(HTMLString(html:com).asSafeMarkdownAttributedString)
            .font(.caption)
          .padding(8)
        }
      }
    }
    .contextMenu(
      ContextMenu {
        if let imageURL = imageURL {
          ShareLink(item: imageURL, message: Text(effectiveFilename))
        }
        Button(action: {
          UIApplication.shared.open(
            FourChanWebEndpoint.post(
              board: self.board,
              thread: self.threadNo,
              post: self.post.no
            ).url
          )
        }
        ) {
          Image(systemName: "globe")
          Text("Show post")
        }
      })
  }
  
  var hasImage : Bool {
    post.tim != nil
  }
  
  var metrics: (CGFloat, CGFloat, CGFloat) {
    func convert(_ a:Int?, _ b:Int?, _ d:Int) -> CGFloat {
      CGFloat(a ?? b ?? d)
    }
    let width = convert(post.w, post.tn_w, 160)
    let height = convert(post.h, post.tn_h, 160)
    if post.h == 0 {
      return (width, height, CGFloat(1.0))
    }
    return (width, height, width / height)
  }
    
  var effectiveFilename: String {
    if let filename = post.filename {
      return filename
    }
    if let tim = post.tim {
      if let ext = post.ext {
        return "\(tim).\(ext)"
      }
      return "\(tim)"
    }
    return "post \(post.id)"
  }
  
  var imageURL : URL? {
    guard let tim = post.tim else {
      return nil
    }
    return FourChanAPIEndpoint.image(board:board, tim:tim, ext:post.ext ?? "").url()
  }
  
  @ViewBuilder
  var image: some View {
      if let tim = post.tim {
        if let ext = post.ext {
          if isDisplayable(ext) {
            ImageView(board:board, tim: tim, ext: ext, width: post.w, height: post.h)
          } else if isGif(ext) {
            AnimatedGifView(board:board, tim: tim, ext: ext)
          } else if isVLCViewable(ext) {
            let width = post.w ?? 160
            let height = post.h ?? 160
            let mediaURL = FourChanAPIEndpoint.image(board:board, tim:tim, ext:ext).url()
            VLCView(mediaURL: mediaURL, width: width, height: height)
          } else {
            ThumbnailView(board:board, tim: tim, width: post.tn_w, height: post.tn_h)
          }
        } else {
          ThumbnailView(board:board, tim: tim, width: post.tn_w, height: post.tn_h)
        }
    }
  }
  
  var subject: String? {
    if let sub = post.sub {
      return HTMLString(html: sub).asRawText
    }
    return nil
  }
  
  func isDisplayable(_ ext: String) -> Bool {
    ext == ".jpg" || ext == ".png"
  }
  
  func isGif(_ ext: String) -> Bool {
    ext == ".gif"
  }
  
  func isVLCViewable(_ ext: String) -> Bool {
    ext == ".webm"
  }

}

struct PostView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
