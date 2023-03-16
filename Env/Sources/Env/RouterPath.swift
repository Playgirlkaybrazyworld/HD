import Combine
import SwiftUI

public enum RouterDestination: Hashable {
  case boards
  case catalog(board: String)
  case thread(board: String, threadNo: Int)
}

@MainActor
public class RouterPath: ObservableObject {
  @Published public var selection: String?
  @Published public var path: NavigationPath

  public init() {
    path = NavigationPath()
  }

  public func navigate(to: RouterDestination) {
    path.append(to)
  }
  
  public func popToRoot() {
    print(path)
  }
}
