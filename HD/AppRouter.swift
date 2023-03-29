import Env
import Foundation
import SwiftUI

@MainActor
extension View {
  func withAppRouter() -> some View {
    navigationDestination(for: RouterDestination.self) { destination in
      switch destination {
      case .boards:
        Text("boards")
      case let .catalog(board, title):
        CatalogView(board: board, title:title)
      case let .thread(title, board, threadNo):
        ThreadView(title:title, board:board, threadNo: threadNo)
      }
    }
  }
}
