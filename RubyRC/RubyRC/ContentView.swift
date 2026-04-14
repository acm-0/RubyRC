//
//  ContentView.swift
//  RubyRC
//
//  Created by Adam Malamy on 3/27/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Image("cabbackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea() // fills entire screen
                .offset(x: -60, y: 0)
            
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
