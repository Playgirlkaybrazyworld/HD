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
  let thumbnailSizeBreakpoint: CGFloat = 128.0
  @ScaledMetric var height: CGFloat = 100.0
  @ScaledMetric var textSpacing: CGFloat = 2.0
  @ScaledMetric var hSpacing: CGFloat = 2.0

  var body: some View {
    if height < thumbnailSizeBreakpoint {
      // Normal size layout
      HStack(alignment:.top) {
        textSummary
        Spacer()
        thumbnail
      }
    } else {
      // large size alignment
      VStack (alignment:.leading) {
        textSummary
        HStack {
          Spacer()
          thumbnail
        }
      }
    }
  }
  
  @ViewBuilder
  var thumbnail: some View {
    if let tim = thread.tim {
      ThumbnailView(board: board, tim: tim, width: thread.tn_w, height: thread.tn_h, maxSize: height)
        .shadow(
          color: .primary,
          radius: 1.0,
          x: 1.0,
          y: 1.0)
        .invisibleWhenNotActive()
        .accessibilityHidden(true)
    }
  }
  
  @ViewBuilder
  var textSummary: some View {
    VStack(alignment:.leading){
      VStack(alignment:.leading, spacing:textSpacing) {
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
        }
      }
      Spacer()
      HStack(spacing:hSpacing){
        let replies = thread.replies ?? 0
        let images = thread.images ?? 0
        if replies > 0 {
          HStack(spacing: hSpacing) {
            Image(systemName: "bubble.left")
            Text("\(replies)")
          }
          .accessibilityElement(children: .ignore)
          .accessibilityLabel("\(replies) replies")
        }
        if replies > 0 && images > 0 {
          Text("•")
          .accessibilityHidden(true)
        }
        if images > 0 {
          HStack(spacing: hSpacing) {
            Image(systemName: "photo")
            Text("\(images)")
          }
          .accessibilityElement(children: .ignore)
          .accessibilityLabel("\(images) images")
        }
      }
      .font(.caption)
      .foregroundColor(.secondary)
    }
    .frame(height:height)
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
