import Combine
import Foundation
import SwiftUI
import os

public final class Client: ObservableObject {  
  private let urlSession: URLSession
  private let decoder = JSONDecoder()

  public init() {
    urlSession = URLSession.shared
  }

  private func makeURLRequest(url: URL, endpoint: Endpoint, httpMethod: String) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod
    return request
  }

    private func makeURL(scheme: String = "https",
                         endpoint: Endpoint,
                         forceServer: String? = nil) -> URL
    {
      var components = URLComponents()
      components.scheme = scheme
      components.host = forceServer ?? endpoint.host
      components.path = endpoint.path
      components.queryItems = endpoint.queryItems
      return components.url!
    }

  private func makeGet(endpoint: Endpoint) -> URLRequest {
    let url = makeURL(endpoint: endpoint)
    return makeURLRequest(url: url, endpoint: endpoint, httpMethod: "GET")
  }

  public func get<Entity: Decodable>(endpoint: Endpoint) async throws -> Entity {
    try await makeEntityRequest(endpoint: endpoint, method: "GET")
  }

  private func makeEntityRequest<Entity: Decodable>(endpoint: Endpoint,
                                                    method: String) async throws -> Entity
  {
    let url = makeURL(endpoint: endpoint)
    let request = makeURLRequest(url: url, endpoint: endpoint, httpMethod: method)
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
