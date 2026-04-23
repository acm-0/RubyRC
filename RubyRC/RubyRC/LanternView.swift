//
//  LanternView.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/22/26.
//
import SwiftUI

struct LanternView: View {
    let isConnected: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let gw = geometry.size.width
            let gh = geometry.size.height
            Image(
                isConnected ? "bluelantern" : "redlantern"
            )
            .resizable()
            .scaleEffect(0.2)
            .position(x: gw * 0.5, y: gh * 0.5)
            Image("bluetooth-icon")
                .renderingMode(.template)  // Treat it as a mask
                .resizable()
                .scaledToFit()
                .scaleEffect(0.04)
                .foregroundStyle(.white)  // Apply the red tint
                .position(x: gw * 0.49, y: gh * 0.51)
        }
    }
}

#Preview {
    LanternView(isConnected: true)
}
