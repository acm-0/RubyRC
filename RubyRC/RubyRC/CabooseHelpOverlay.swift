//
//  CabooseHelpOverlay 2.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/28/26.
//


//
//  HelpOverlay.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/23/26.
//

import SwiftUI

struct CabooseHelpOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            let gw = geometry.size.width
            let gh = geometry.size.height
            Text("Automatic\nSpeed\nControl\nSwitch")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .position(x: gw * 0.6, y: gh * 0.48)
            Image(systemName: "arrow.right")
                .font(.largeTitle)
                .foregroundColor(.white)
                .position(x: gw * 0.7, y: gh * 0.48)
            Text("Emergency\nStop")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .position(x: gw * 0.6, y: gh * 0.21)
            Image(systemName: "arrow.right")
                .font(.largeTitle)
                .foregroundColor(.white)
                .position(x: gw * 0.7, y: gh * 0.23)
            Text("Speed")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .position(x: gw * 0.40, y: gh * 0.3)
            Text("Red Tender\nLED Switch")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .position(x: gw * 0.2, y: gh * 0.43)
            Image(systemName: "arrow.right")
                .font(.largeTitle)
                .foregroundColor(.white)
                .position(x: gw * 0.34, y: gh * 0.43)
            Text("Throttle")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .position(x: gw * 0.72, y: gh * 0.84)
            Text("off")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .position(x: gw * 0.82, y: gh * 0.66)
            Text("max")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .position(x: gw * 0.82, y: gh * 0.90)
            Text("Johnson Bar")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .position(x: gw * 0.3, y: gh * 0.84)
            Text("forward")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .position(x: gw * 0.12, y: gh * 0.70)
            Text("neutral")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .position(x: gw * 0.08, y: gh * 0.81)
            Text("reverse")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .position(x: gw * 0.12, y: gh * 0.91)
            Text("Bluetooth Lantern\nred - disconnected\nblue - connected")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
                .position(x: gw * 0.23, y: gh * 0.11)
            Image(systemName: "arrow.down")
                .font(.largeTitle)
                .foregroundColor(.white)
                .position(x: gw * 0.08, y: gh * 0.16)
            Text("        Show Help")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
                .position(x: gw * 0.52, y: gh * 0.03)
            Image(systemName: "arrow.left")
                .font(.largeTitle)
                .foregroundColor(.white)
                .position(x: gw * 0.4, y: gh * 0.03)
            Text("Go To\nSettings")
                .padding(6)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .position(x: gw * 0.86, y: gh * 0.10)
            Image(systemName: "arrow.up")
                .font(.largeTitle)
                .foregroundColor(.white)
                .position(x: gw * 0.93, y: gh * 0.07)
        }
    }
}

#Preview {
    CabooseHelpOverlay()
}
