import Foundation
import FourChan

class BoardsViewModel : ObservableObject {
  @Published var scrollToBoard: String?
  @Published var boardsState: BoardsState = .loading
  
  var visibleBoards = Set<String>()
  var scrollToBoardAnimated: Bool = false
  
  func appeared(board: String) {
    visibleBoards.insert(board)
  }
  
  func disappeared(board: String) {
    visibleBoards.remove(board)
  }
  
  var topVisibleBoard: String? {
    visibleBoards.sorted().first
  }
  
  func index(board:String)->Int? {
    if case let .display(boards) = boardsState {
      return boards.firstIndex{ $0.id == board }
    }
    return nil
  }
}

public enum BoardsState {
  case loading
  case display(boards: [Board])
  case error(error: Error)
}
