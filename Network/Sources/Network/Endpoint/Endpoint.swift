import Foundation

/// The endpoints that make up the read-only 4chan API.
///
/// See https://github.com/4chan/4chan-API
public enum Endpoint : Sendable {
  case boards
  case catalog(board: String)
  case thread(board: String, no: Int)
  case threads(board: String, page: Int)
  
  /// The threads have minimal information filled in.
  case allThreads(board: String)
  
  case archive(board: String)
  case image(board: String, tim: Int, ext: String)
  case thumbnail(board: String, tim: Int)
  case spoilerImage
  case flag(country: String)
  case polFlag(country: String)
  case boardFlag(board: String, code: String)
  case customSpoiler(board: String, index: Int)
  
  /// Mobile Search endpoint. Takes additional query parameters.
  case search
}

extension Endpoint {
  enum HostType {
    case api
    case image
    case staticImage
    case search
  }
  
  private var hostType: HostType {
    switch self {
    case .boards, .catalog, .thread, .threads, .allThreads, .archive:
      return .api
    case .image, .thumbnail:
      return .image
    case .spoilerImage, .flag, .polFlag, .boardFlag, .customSpoiler:
      return .staticImage
    case .search:
      return .search
    }
  }
  
  var host : String {
    switch hostType {
    case .api:
      return "a.4cdn.org"
    case .image:
      return "i.4cdn.org"
    case .staticImage:
      return "s.4cdn.org"
    case .search:
      return "find.4channel.org"
    }
  }
  
  var path: String {
    switch self {
    case .boards:
      return "/boards.json"
    case let .catalog(board):
      return "/\(board)/catalog.json"
    case let .thread(board, no):
      return "/\(board)/thread/\(no).json"
    case let .threads(board, page):
      return "/\(board)/\(page).json"
    case let .allThreads(board):
      return "/\(board)/threads.json"
    case let .archive(board):
      return "/\(board)/archive.json"
    case let .image(board, tim, ext):
      return "/\(board)/\(tim)\(ext)"
    case let .thumbnail(board, tim):
      return "/\(board)/\(tim)s.jpg"
    case .spoilerImage:
      return "/image/spoiler.png"
    case let .flag(country):
      return "/image/country/\(country.lowercased()).gif"
    case let .polFlag(country):
      return "/image/country/troll/\(country).gif"
    case let .boardFlag(board, code):
      return "/image/flags/\(board)/\(code.lowercased()).gif"
    case let .customSpoiler(board, index):
      return "/image/spoiler-\(board)\(index).png"
    case .search:
      // desktop browser search API. Only searches SFW boards.
      return "/api"
      // Broken all-boards mobile search https://p.4chan.org/api/search"
    }
  }
  
  public var queryItems: [URLQueryItem]? {
    return nil
  }
}
