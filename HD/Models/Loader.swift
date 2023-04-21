import Blackbird
import FourChan
import Network
import SwiftUI

struct Loader {
  var database: Blackbird.Database
  var client: Client
  
  func load(endpoint: FourChan.FourChanAPIEndpoint) async throws {
    switch endpoint {
    case .boards:
      let fourChanBoards: Boards = try await client.get(endpoint: endpoint)
      try await database.transaction { core in
        try fourChanBoards.boards.forEach { fourChanBoard in
          try Board(id: fourChanBoard.id, title: fourChanBoard.title).writeIsolated(to: database, core: core)
        }
        // TODO: Delete old boards, delete threads for old boards, delete posts for old boards.
      }
    case let .catalog(board:boardId):
      let catalog: Catalog = try await client.get(endpoint: endpoint)
      let fourChanThreads = catalog.flatMap(\.threads)
      try await database.transaction { core in
        try fourChanThreads.forEach {
          try dbPost($0, boardId: boardId, threadId: $0.no).writeIsolated(to: database, core: core)
        }
        // TODO: Delete old threads, delete posts for old threads.
      }
    case let .thread(board: boardId, no:threadNo):
      let thread: ChanThread? = try await client.get(endpoint: endpoint)
      let fourChanPosts = thread?.posts ?? []
      try await database.transaction { core in
        try fourChanPosts.forEach {
          try dbPost($0, boardId:boardId, threadId:threadNo).writeIsolated(to: database, core: core)
        }
        // TODO: Delete old posts in thread.
      }
    default:
      print("Unhandled entry")
    }
  }
  
  func dbPost(_ p: FourChan.Post, boardId: String, threadId: Int) -> Post {
    Post(
      id: p.id,
      boardId: boardId,
      isThread: threadId == p.id,
      threadId: threadId,
      sub: p.sub,
      com: p.com,
      tim: p.tim,
      filename: p.filename,
      ext: p.ext,
      w: p.w,
      h: p.h,
      tn_w: p.tn_w,
      tn_h: p.tn_h,
      replies: p.replies,
      images: p.images
    )
  }
}

struct EnvironmentLoaderKey: EnvironmentKey {
    static var defaultValue: Loader? = nil
}

extension EnvironmentValues {
    var loader: Loader? {
        get { self[EnvironmentLoaderKey.self] }
        set { self[EnvironmentLoaderKey.self] = newValue }
    }
}
