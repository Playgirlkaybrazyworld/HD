//
//  PostView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Models
import SwiftUI

struct PostView: View {
  let board: String
  let post: Post
  var body: some View {
    ScrollView {
      VStack(alignment:.leading) {
        Text("\(post.no) \(post.sub?.asRawText ?? "")")
        if let tim = post.tim {
          if let ext = post.ext {
            ImageView(board:board, tim: tim, ext: ext, width: post.w, height: post.h)
          } else {
            ThumbnailView(board:board, tim: tim, width: post.tn_w, height: post.tn_h)
          }
        }
        if let com = post.com {
          Text(com.asSafeMarkdownAttributedString)
        }
      }
    }
  }
}

struct PostView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
