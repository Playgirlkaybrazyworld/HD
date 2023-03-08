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
      VStack {
        Text("\(post.no) \(post.sub?.asRawText ?? "")")
        if let tim = post.tim {
          if let ext = post.ext {
            ImageView(board:board, tim: tim, ext: ext)
          } else {
            ThumbnailView(board:board, tim: tim)
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
