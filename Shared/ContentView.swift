//
//  ContentView.swift
//  Shared
//
//  Created by DeShawn Jackson on 6/28/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            RealmResultsView<Object>()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
