//
//  PostView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

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
        if let subject = self.subject {
          Text(subject).padding()
        }
        if hasImage {
          HStack {
            Spacer()
            image
            Spacer()
          }
        }
        if let com = post.com {
          Text(HTMLString(html:com).asSafeMarkdownAttributedString)
          .padding()
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
              post: self.post.id
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
              .aspectRatio(CGFloat(post.w!) / CGFloat(post.h!), contentMode: .fill)
              .frame(maxWidth:CGFloat(post.w!), maxHeight:CGFloat(post.h!))
          } else if isAnimatable(ext) {
            VLCView(board:board, tim: tim, ext: ext, width: post.w, height: post.h)
              .aspectRatio(CGFloat(post.w!) / CGFloat(post.h!), contentMode: .fill)
              .frame(maxWidth:CGFloat(post.w!), maxHeight:CGFloat(post.h!))
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
  
  func isAnimatable(_ ext: String) -> Bool {
    ext == ".webm"
  }

}

struct PostView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
