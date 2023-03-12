import Combine

public enum RouterDestination: Hashable {
  case boards
  case catalog(board: String)
  case thread(board: String, threadNo: Int)
}

@MainActor
public class RouterPath: ObservableObject {
  @Published public var selection : RouterDestination?
  @Published public var path: [RouterDestination] = []

  public init() {}

  public func navigate(to: RouterDestination) {
    path.append(to)
  }
  
  public func popToRoot() {
    print(path)
  }
}
