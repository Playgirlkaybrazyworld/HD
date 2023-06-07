import FourChan
import Foundation
import SwiftUI
import os

public final class Client: ObservableObject {  
  private let urlSession: URLSession
  private let decoder = JSONDecoder()
  
  public init() {
    urlSession = URLSession.shared
  }
  
  public func makeURL(endpoint: FourChanAPIEndpoint) -> URL {
    endpoint.url()
  }
  
  private func makeURLRequest(endpoint: FourChanAPIEndpoint, httpMethod: String) -> URLRequest {
    var request = URLRequest(url: endpoint.url())
    request.httpMethod = httpMethod
    return request
  }
    
  private func makeGet(endpoint: FourChanAPIEndpoint) -> URLRequest {
    return makeURLRequest(endpoint: endpoint, httpMethod: "GET")
  }
  
  public func get<Entity: Decodable>(endpoint: FourChanAPIEndpoint) async throws -> Entity {
    try await makeEntityRequest(endpoint: endpoint, method: "GET")
  }
  
  private func makeEntityRequest<Entity: Decodable>(endpoint: FourChanAPIEndpoint,
                                                    method: String) async throws -> Entity
  {
    let request = makeURLRequest(endpoint: endpoint, httpMethod: method)
    let (data, httpResponse) = try await urlSession.data(for: request)
    logResponseOnError(httpResponse: httpResponse, data: data)
    return try decoder.decode(Entity.self, from: data)
  }
  
  private func logResponseOnError(httpResponse: URLResponse, data: Data) {
    if let httpResponse = httpResponse as? HTTPURLResponse, httpResponse.statusCode > 299 {
      print(httpResponse)
      print(String(data: data, encoding: .utf8) ?? "")
    }
  }
}

extension Client: Sendable {}
