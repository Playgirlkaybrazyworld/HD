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
      case let .catalog(board):
        CatalogView(board: board)
      case let .thread(board, threadNo):
        ThreadView(board:board, threadNo: threadNo)
      }
    }
  }
}
