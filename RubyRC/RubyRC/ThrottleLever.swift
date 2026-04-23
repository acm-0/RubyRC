//
//  ThrottleLever.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/15/26.
//

import SwiftUI

struct ThrottleLever: View {
    @Binding var currentAngle: Double
    let minAngle: Double
    let maxAngle: Double
    
    // Pivot at 90% width, 50% height
    let pivotPoint = UnitPoint(x: 0.5, y: 0.5)

    var body: some View {
        GeometryReader { geo in
            let gw = geo.size.width
            let gh = geo.size.height
            let pivotInScreen = CGPoint(
                x: gw * pivotPoint.x,
                y: gh * pivotPoint.y
            )
            
            // This ZStack ensures we have a touch area even if the image is thin
            ZStack {
                // THE LEVER SHAPE
                Image("lever")
                    .scaledToFit()
                    .rotationEffect(Angle(degrees: 90))
                    .scaleEffect(x: 0.4, y: 0.6)
                    .position(x: gw * 0.72, y: gh/2)
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.orange)
//                    .overlay(
//                        Text("HANDLE")
//                            .font(.caption2)
//                            .rotationEffect(.degrees(-currentAngle)) // Keep text upright
//                    )
                    .rotationEffect(.degrees(currentAngle), anchor: pivotPoint)
                
                // THE HINGE (Visual indicator of the pivot)
//                Circle()
//                    .fill(.white)
//                    .frame(width: 10, height: 10)
//                    .position(pivotInScreen)
            }
            .background(Color.white.opacity(0.05)) // See the hit-box area
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let vX = value.location.x - pivotInScreen.x
                        let vY = value.location.y - pivotInScreen.y
                        let radians = atan2(vY, vX)
                        var degrees = radians * 180 / .pi
                        
//                        if degrees < 0 { degrees += 360 }
                        
                        // Use a wider clamp for testing if needed
                        currentAngle = min(max(degrees, minAngle), maxAngle)
                    }
            )
        }
    }
}

struct ThrottleLeverPreview: View {
    @State private var angle: Double = 180
    
    var body: some View {
        // Use a simple VStack first to ensure visibility
//        VStack {
//            Text("Angle: \(Int(angle))°")
//                .font(.largeTitle)
            
//            Spacer()
            
            // Placing the lever inside a defined frame
            // is the only way to ensure it appears in Preview.
            ThrottleLever(currentAngle: $angle, minAngle: -90, maxAngle: 90)
                .frame(width: 300, height: 300)
//                .border(Color.blue) // Visualizes the component bounds
            
//            Spacer()
    //}
//        .padding()
        // Removed the black background temporarily to ensure you see the UI
    }
}

#Preview {
    ThrottleLeverPreview()
}
