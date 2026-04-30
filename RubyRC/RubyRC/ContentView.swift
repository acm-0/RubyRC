//
//  ContentView.swift
//  RubyRC
//
//  Created by Adam Malamy on 3/27/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var gotoSettings = false
        
        var body: some View {
            ZStack {
                // Layer 1: The Main Engine Cab
                // This stays loaded in the background even when hidden
                MainCabView(gotoSettings: $gotoSettings)
                    .opacity(gotoSettings ? 0 : 1)
                    .disabled(gotoSettings) // Prevents clicking hidden buttons
                
                // Layer 2: The Caboose (Settings)
                // This sits on top of the Cab
                CabooseView(isOn: $gotoSettings)
                    .opacity(gotoSettings ? 1 : 0)
                    .disabled(!gotoSettings)
            }
            .environmentObject(bluetoothManager)
            .animation(.easeInOut(duration: 0.4), value: gotoSettings)
        }
}  // Struct

#Preview {
    ContentView()
}
