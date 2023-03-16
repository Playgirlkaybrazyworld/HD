import Combine
import SwiftUI

public enum RouterDestination: Hashable, Codable {
  case boards
  case catalog(board: String)
  case thread(board: String, threadNo: Int)
}

@MainActor
public class RouterPath: ObservableObject {
  @Published public var selection: String?
  @Published public var path: NavigationPath
  
  private struct StorageModel: Codable {
    public var selection: String?
    public var path: NavigationPath
    
    private enum CodingKeys: String, CodingKey {
      case selection
      case path
    }
    
    public init(selection: String?, path:NavigationPath) {
      self.selection = selection
      self.path = path
    }
    
    public init(from decoder: Decoder) throws {
      let data = try decoder.container(keyedBy: CodingKeys.self)
      self.selection = try data.decode(String?.self, forKey: .selection)
      self.path = NavigationPath(try data.decode(NavigationPath.CodableRepresentation.self, forKey: .path))
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(selection, forKey: .selection)
      try container.encode(path.codable, forKey: .path)
    }
  }
  
  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()
  
  public func encoded() -> Data? {
    let model = StorageModel(selection: selection, path: path)
    return try? encoder.encode(model)
  }
  
  public func restore(from data: Data) {
    do {
      let model = try decoder.decode(
        StorageModel.self, from: data
      )
      self.path = model.path
      self.selection = model.selection
    } catch {
      selection = nil
      path = NavigationPath()
    }
  }
  
  
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
