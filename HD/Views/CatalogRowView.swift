//
//  CatalogRowView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Models
import SwiftUI

struct CatalogRowView: View {
  let thread: Post
  var body: some View {
    if let sub = thread.sub {
      Text(sub.asSafeMarkdownAttributedString)
    } else if let com = thread.com {
      Text(com.asSafeMarkdownAttributedString).lineLimit(3)
    } else {
      Text("\(thread.id)")
    }
  }
}

struct CatalogRowView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
