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
        if let tim = post.tim {
          if let ext = post.ext {
            if isDisplayable(ext) {
              ImageView(board:board, tim: tim, ext: ext, width: post.w, height: post.h)
            } else if isGifu(ext) {
              Text("Gif!!")
            } else if isAnimatable(ext) {
              Text("Webm!!")
            } else {
              ThumbnailView(board:board, tim: tim, width: post.tn_w, height: post.tn_h)
            }
          } else {
            ThumbnailView(board:board, tim: tim, width: post.tn_w, height: post.tn_h)
          }
        }
        if let com = post.com {
          Text(HTMLString(html:com).asSafeMarkdownAttributedString)
          .padding()
        }
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
  
  func isGifu(_ ext: String) -> Bool {
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
