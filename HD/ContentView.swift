//
//  ContentView.swift
//  HD
//
//  Created by Jack Palevich on 3/6/23.
//

import Models
import Network
import SwiftUI

struct ContentView: View {
  
  var body: some View {
    NavigationStack {
      BoardsView()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
    .environmentObject(Client())
  }
}
