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
    Text(thread.sub?.asRawText ?? thread.com?.asRawText ?? "\(thread.id)").lineLimit(3)
  }
}

struct CatalogRowView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
