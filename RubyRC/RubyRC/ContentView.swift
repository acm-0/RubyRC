//
//  ContentView.swift
//  RubyRC
//
//  Created by Adam Malamy on 3/27/26.
//

import SwiftUI

struct ContentView: View {
    var isConnected = false
    let colorized = true
    @State var isOn = false
    @State var emergencyStop = true
    var body: some View {
        ZStack {
            Image(colorized ? "colorizedcab" : "cabbackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()  // fills entire screen
                .offset(x: -75, y: 0)
            Image(isConnected ? "bluelantern" : "redlantern")
                .resizable()
                .scaleEffect(0.2)
                .offset(x: -163, y: -200)
            Image("bluetooth-icon")
                .renderingMode(.template)  // Treat it as a mask
                .resizable()
                //                .frame(width:60)
                .scaledToFit()
                .scaleEffect(0.03)
                .foregroundStyle(.white)  // Apply the red tint
                .offset(x: -173, y: -193)

            Button {
                // Simply flip the boolean state
                isOn.toggle()
            } label: {
                // Switch the image based on the state
                Image(isOn ? "onoffon" : "onoffoff")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .animation(nil, value: isOn)  // Turns off brief fade when button is pressed
            }
            .offset(x: 135, y: 0)
            // This prevents the button from turning blue or fading when clicked
            .buttonStyle(.plain)
            Button {
                emergencyStop.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    emergencyStop = false
                }
            } label: {
                Image("redbutton2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                    .shadow(color: emergencyStop ? .red : .clear, radius: 20)
                    .animation(nil, value: emergencyStop)
            }
            .offset(x: 110, y: -180)
            .buttonStyle(.plain)
            Image("lever")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .scaleEffect(x: 0.9, y: 0.5)
                .offset(x: -80, y: 140)
            Image("lever")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .scaleEffect(x: 0.9, y: 0.5)
                .rotationEffect(.degrees(270))
                .offset(x: -140, y: 220)
                .padding()
        }
    }
}

#Preview {
    ContentView()
}
