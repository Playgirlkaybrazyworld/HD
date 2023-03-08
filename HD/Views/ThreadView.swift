//
//  ThreadView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Models
import Network
import SwiftUI

struct ThreadView: View {
  @EnvironmentObject private var client: Client
  let board: String
  let thread: Post
  @State private var posts: Posts = []
  var body: some View {
    List(posts){post in
      NavigationLink {
        PostView(board:board, post:post)
      } label: {
        ThreadRowView(post:post)
      }
    }
    .onAppear {
      Task {
        let thread: ChanThread = try await client.get(endpoint: .thread(board:board, no:thread.no))
        withAnimation {
          self.posts = thread.posts
        }
      }
    }
  }
}

struct ThreadView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
