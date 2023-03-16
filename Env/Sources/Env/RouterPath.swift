import Combine
import SwiftUI

public enum RouterDestination: Hashable, Codable {
  case boards
  case catalog(board: String)
  case thread(board: String, threadNo: Int)
}

@MainActor
public class RouterPath: ObservableObject {
  @Published public var path: [RouterDestination]
  
  private struct StorageModel: Codable {
    public var path: [RouterDestination]
    
    private enum CodingKeys: String, CodingKey {
      case path
    }
    
    public init(path:[RouterDestination]) {
      self.path = path
    }
    
    public init(from decoder: Decoder) throws {
      let data = try decoder.container(keyedBy: CodingKeys.self)
      self.path = try data.decode([RouterDestination].self, forKey: .path)
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(path, forKey: .path)
    }
  }
  
  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()
  
  public func encoded() -> Data? {
    let model = StorageModel(path: path)
    return try? encoder.encode(model)
  }
  
  public func restore(from data: Data) {
    do {
      let model = try decoder.decode(
        StorageModel.self, from: data
      )
      self.path = model.path
    } catch {
      path = []    }
  }
  
  
  public init() {
    path = []
  }
  
  public func navigate(to: RouterDestination) {
    switch to {
    case .boards:
      path = []
    case .catalog:
      path = [to]
    case .thread:
      path.append(to)
    }
  }
  
  public func popToRoot() {
    print(path)
  }
}
