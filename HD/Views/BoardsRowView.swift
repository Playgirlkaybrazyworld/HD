//
//  BoardsRowView.swift
//  HD
import FourChan
import SwiftUI

struct BoardsRowView: View {
  let board: Board
  var body: some View {
    HStack {
      Text(board.title)
      Spacer()
      Text(board.id)
        .speechSpellsOutCharacters(true)
        .foregroundColor(.secondary)
    }
    .accessibilityElement(children: .combine)
  }
}

struct BoardsRowView_Previews: PreviewProvider {
  static var previews: some View {
    Text("TBD")
  }
}
