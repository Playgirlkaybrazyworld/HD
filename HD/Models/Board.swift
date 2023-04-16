//
//  Board.swift
//  HD
//
//  Created by Jack Palevich on 4/16/23.
//

import Blackbird

struct Board : BlackbirdModel {
  @BlackbirdColumn var id: String
  @BlackbirdColumn var title: String
}
