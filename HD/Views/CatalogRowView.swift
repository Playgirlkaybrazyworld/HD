//
//  CatalogRowView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import FourChan
import SwiftUI

struct CatalogRowView: View {
  let board: String
  let thread: Post
  var body: some View {
    HStack(alignment:.top) {
      if let tim = thread.tim {
        ThumbnailView(board: board, tim: tim, width: thread.tn_w, height: thread.tn_h, maxSize: 100.0)
      }
      if let sub = thread.sub {
        Text(sub.asSafeMarkdownAttributedString)
      } else if let com = thread.com {
        Text(com.asSafeMarkdownAttributedString).lineLimit(3)
      } else {
        Text("\(thread.id)")
      }
    }
  }
}

struct CatalogRowView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
