//
//  SpeedometerView.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/15/26.
//


import SwiftUI

struct SpeedometerView: View {
    var speed: UInt32 // Value from 0 to 60
    @Binding var ledOn: Bool
    
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
                Button {
                    // Simply flip the boolean state
                    ledOn.toggle()
                } label: {Image("smallbutton")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.1)
                        .position(x: gw * 0.5, y: gh * 0.575)
                        .shadow(color: ledOn ? .red : .clear, radius: 10)
                }
                .buttonStyle(.plain)
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
            }
        }
    }
}

#Preview {
    SpeedometerPreviewWrapper()
}

struct SpeedometerPreviewWrapper: View {
    @State private var ledOn = false
    
    var body: some View {
        SpeedometerView(speed: 30, ledOn: $ledOn)
//            .frame(width: 300, height: 300)
//            .background(Color.gray.opacity(0.2)) // helps see layout
    }
}
