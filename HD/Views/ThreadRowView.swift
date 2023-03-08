//
//  ThreadRowView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Models
import SwiftUI

struct ThreadRowView: View {
  let post: Post
  var body: some View {
    Text("\(post.no) \(post.sub ?? "")")
  }
}

struct ThreadRowView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
