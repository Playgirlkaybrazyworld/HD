//
//  BoardsRowView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import FourChan
import SwiftUI

struct BoardsRowView: View {
  let board: Board
  var body: some View {
    HStack {
      Text(board.title)
      Spacer()
      Text(board.id)
    }
  }
}

struct BoardsRowView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
