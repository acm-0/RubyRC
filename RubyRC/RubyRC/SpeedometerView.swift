//
//  SpeedometerView.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/15/26.
//


import SwiftUI

struct SpeedometerView: View {
    var speed: UInt32 // Value from 0 to 60
    
    var body: some View {
        GeometryReader { geometry in
            let gw = geometry.size.width
            let gh = geometry.size.height
            ZStack {
                Image("speedodial5")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.4)
                    .position(x: gw * 0.499, y: gh * 0.502)
                // 3. The Needle
                Image("needle")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.25)
                    .position(x: gw * 0.55, y: gh * 0.5)

                    .rotationEffect(
                        .degrees(0),
//                        anchor: UnitPoint(x: 0.11, y: 0.5)
                    )

                //                .rotationEffect(.degrees(-135)) // Starting position (0 MPH)
                    .rotationEffect(.degrees(Double(speed) / 60 * 270 + 135)//,
//                anchor: UnitPoint(x: 10, y: 10)// Calculate rotation based on speed
                                    )
                    .animation(.easeInOut(duration: 0.5), value: speed)
                
                // 4. The Center Hub
                Circle()
                    .fill(Color.black)
                    .scaleEffect(0.01)
 //                   .frame(width: 4, height: 4)
                    .position(x: gw/2, y: gh/2)
//                // 5. Digital Readout
//                VStack {
//                    Spacer()
//                    Text("\(Int(speed))")
//                        .font(.system(size: 40, weight: .bold, design: .monospaced))
//                    Text("MPH")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//                .offset(y: 40)
            }
        }
    }
}

#Preview {
    SpeedometerView(speed:20)
}
