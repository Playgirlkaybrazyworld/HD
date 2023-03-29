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
  let height: CGFloat = 100
  var body: some View {
    HStack(alignment:.top) {
      VStack(alignment:.leading){
        VStack(alignment:.leading, spacing:2) {
          if let sub = thread.sub {
            Text(HTMLString(html: sub)
              .asSafeMarkdownAttributedString)
            .lineLimit(2)
            .font(.headline)
            .fixedSize(horizontal: false, vertical:true)
          }
          if let com = thread.com {
            Text(HTMLString(html:com).asSafeMarkdownAttributedString)
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
        }
        Spacer()
        HStack(spacing:2){
          let replies = thread.replies ?? 0
          let images = thread.images ?? 0
          if replies > 0 {
            Image(systemName: "bubble.left")
            Text("\(replies)")
          }
          if replies > 0 && images > 0 {
            Text("•")
          }
          if images > 0 {
            Image(systemName: "photo")
            Text("\(images)")
          }
        }
        .font(.caption)
        .foregroundColor(.secondary)
      }
      .frame(height:height)
      Spacer()
      if let tim = thread.tim {
        ThumbnailView(board: board, tim: tim, width: thread.tn_w, height: thread.tn_h, maxSize: height)
          .shadow(
            color: .primary,
            radius: 1.0,
            x: 1.0,
            y: 1.0)
          .invisibleWhenNotActive()
      }
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
