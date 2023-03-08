//
//  BoardsRowView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Models
import SwiftUI

struct BoardsRowView: View {
  let board: Board
  var body: some View {
    Text("\(board.id)")
  }
}

struct BoardsRowView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
