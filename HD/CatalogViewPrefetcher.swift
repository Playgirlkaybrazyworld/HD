import Models
import Network
import Nuke
import SwiftUI
import UIKit

final class CatalogViewPrefetcher: NSObject, ObservableObject, UICollectionViewDataSourcePrefetching {
  private let prefetcher = ImagePrefetcher()
  
  var client: Client!
  var board: String!
  var posts: Posts = []
  
  func collectionView(_: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    let imageURLs = getImageURLs(for: indexPaths)
    prefetcher.startPrefetching(with: imageURLs)
  }

  func collectionView(_: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    let imageURLs = getImageURLs(for: indexPaths)
    prefetcher.stopPrefetching(with: imageURLs)
  }

  private func getImageURLs(for indexPaths: [IndexPath]) -> [URL] {
    return indexPaths.compactMap { path in
      let row = path.row
      guard row < posts.endIndex else { return nil }
      let post = posts[row]
      return getImageURL(post)
    }
  }
  
  private func getImageURL(_ post: Post) -> URL? {
    guard let tim = post.tim else { return nil }
    return client.makeURL(endpoint: .thumbnail(board: board, tim: tim))
  }
}


