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
  let post: Post
  var body: some View {
    ScrollView {
      VStack(alignment:.leading, spacing: 0) {
        if let subject = self.subject {
          Text(subject).padding()
        }
        image
        if let com = post.com {
          Text(HTMLString(html:com).asSafeMarkdownAttributedString)
          .padding()
        }
      }
    }
  }
  
  @ViewBuilder
  var image: some View {
    HStack{
      if let tim = post.tim {
        Spacer()
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
        Spacer()
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
