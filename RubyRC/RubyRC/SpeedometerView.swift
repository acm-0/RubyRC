//
//  SpeedometerView.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/15/26.
//


import SwiftUI

struct SpeedometerView: View {
    var speed: Double // Value from 0 to 60
    
    var body: some View {
        ZStack {
            // 1. The Outer Face
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                .frame(width: 250, height: 250)
            
            // 2. The Scale Arc (0 to 60 MPH)
            Circle()
                .trim(from: 0, to: 0.75) // Creates a 270-degree arc
                .stroke(
                    AngularGradient(gradient: Gradient(colors: [.green, .yellow, .red]), center: .center),
                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                )
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(135)) // Rotates arc to center at the top

            // 3. The Needle
            Rectangle()
                .fill(Color.red)
                .frame(width: 4, height: 100)
                .offset(y: -50) // Move pivot point to the bottom of the needle
                .rotationEffect(.degrees(-135)) // Starting position (0 MPH)
                .rotationEffect(.degrees(speed / 60 * 270)) // Calculate rotation based on speed
                .animation(.easeInOut(duration: 0.5), value: speed)

            // 4. The Center Hub
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
            
            // 5. Digital Readout
            VStack {
                Spacer()
                Text("\(Int(speed))")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                Text("MPH")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .offset(y: 40)
        }
    }
}

#Preview {
    SpeedometerView(speed: 20.0)
}
