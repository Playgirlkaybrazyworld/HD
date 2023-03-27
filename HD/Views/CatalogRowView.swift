//
//  CatalogRowView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import FourChan
import HTMLString
import SwiftUI

struct CatalogRowView: View {
  let board: String
  let thread: Post
  var body: some View {
    HStack(alignment:.top) {
      if let tim = thread.tim {
        ThumbnailView(board: board, tim: tim, width: thread.tn_w, height: thread.tn_h, maxSize: 100.0)
        .blurWhenNotActive(radius:25.0)
      }
      Text(HTMLString(html:thread.title).asSafeMarkdownAttributedString)
        .lineLimit(3)
    }
  }
}

extension Post {
  var title: String {
    if let title = sub ?? com {
      return HTMLString(html:title).asRawText
    }
    return "\(id)"
  }
}

struct CatalogRowView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
