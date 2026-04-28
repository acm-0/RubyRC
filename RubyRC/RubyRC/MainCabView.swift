//
//  MainCabView.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/27/26.
//


//
//  ContentView.swift
//  RubyRC
//
//  Created by Adam Malamy on 3/27/26.
//

import SwiftUI

struct MainCabView: View {
    @Binding var gotoSettings: Bool
    @State var ascOn = false // asc stand for Automatic Speed Control
    @State var showHelp = false
    @State var emergencyStop = false
//    @State var gotoSettings = false
    @StateObject private var bluetoothManager = BluetoothManager()
    @State var throttlePosition: Double = -45
    @State var johnsonPosition: Double = 165
    @State var redLedOn: Bool = false


    func RawSpeed2Speed(rawSpeed: UInt32) -> UInt32 {
        guard rawSpeed != 0 else { return 0 }
        let speed = UInt32(2000.0 / Double(rawSpeed))
        return speed
    }
    
    var body: some View {
        GeometryReader { geometry in
            let gw = geometry.size.width
            let gh = geometry.size.height
            ZStack {
/* Background */
                Image("colorizedcab")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()  // fills entire screen
                    .position(
                        x: gw * 0.3,  // 30% across the screen
                        y: gh * 0.5  // 50% down from the top
                    )
/* Bluetooth Lantern and Bluetooth Icon */
                LanternView(isConnected: bluetoothManager.isConnected)
                    .position(x: gw * 0.085, y: gh * 0.24)
/* Automatic Speed Control Toggle Switch and Label*/
                Button {
                    // Simply flip the boolean state
                    ascOn.toggle()
                } label: {
                    // Switch the image based on the state
                    Image(ascOn ? "onoffon" : "onoffoff")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                        .animation(nil, value: ascOn)  // Turns off brief fade when button is pressed
                }
                .position(x: gw * 0.81, y: gh * 0.5)
                // This prevents the button from turning blue or fading when clicked
                .buttonStyle(.plain)
                Image("ASC")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.2)
                    .position(x: gw * 0.82, y: gh * 0.38)

/* Help Switch */
                Button {
                    showHelp.toggle()
                } label: {
                    Image("questionmark")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.5)
                        .position(x: gw * 0.3, y: gh * 0.0)
                        .shadow(color: showHelp ? .red : .blue, radius: 10)
                }
                .buttonStyle(.plain)
/* Settings Switch */
                GearView(isOn: $gotoSettings)
                    .position(x: gw * 0.93, y: gh * 0.0)
 //               Button {
//                    gotoSettings.toggle()
//                } label: {
//                    Image("gear")
//                        .resizable()
//                        .scaledToFit()
//                        .scaleEffect(0.4)
//                        .position(x: gw * 0.93, y: gh * 0.0)
////                        .shadow(color: .blue, radius: 0.1)
//                }
/* Emergency Stop Switch */
                Button {
                    emergencyStop.toggle()
                    throttlePosition = -45.0
                    johnsonPosition = 165
                    ascOn = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        emergencyStop = false
                    }
                } label: {
                    Image("redbutton2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                        .shadow(
                            color: emergencyStop ? .red : .clear,
                            radius: 20
                        )
                        .animation(nil, value: emergencyStop)
                }
                .position(x: gw * 0.81, y: gh * 0.25)
                .buttonStyle(.plain)
/* Speedometer */
                SpeedometerView(
                    speed: RawSpeed2Speed(rawSpeed: bluetoothManager.rawSpeed),
                    ledOn: $redLedOn
                )
                .position(x: gw * 0.40, y: gh * 0.36)
/* Throttle Lever */
                ThrottleLever(currentAngle: $throttlePosition)
                    .frame(width:300, height:300)                    .position(x: gw * 0.72, y: gh * 0.785)
/* Johnson Lever */
                JohnsonLever(currentAngle: $johnsonPosition)
                    .frame(width:300, height:300)                    .position(x: gw * 0.28, y: gh * 0.785)
            }  // ZStack
            .onChange(of: redLedOn) {
                let byteValue: UInt8 = redLedOn ? 1 : 0
                bluetoothManager.RedLEDEnable(value: byteValue)
            }
            .onChange(of: johnsonPosition) {
                var command: UInt8
                if johnsonPosition == AppConfig.johnsonBarForwardAngle {command = AppConfig.johnsonBarForwardCode }
                else if johnsonPosition == AppConfig.johnsonBarNeutralAngle {command = AppConfig.johnsonBarNeutralCode }
                else {command = AppConfig.johnsonBarReverseCode}
                bluetoothManager.JohnsonBarWrite(command: command)
            }
/* Help Overlay */
            .overlay {
                if showHelp {
                    HelpOverlay()
                }
            }
        }  // Geometry Reader
    }  // View
}  // Struct

#Preview {
    MainCabPreviewWrapper()
}

struct MainCabPreviewWrapper: View {
    @State private var isOn = false

    var body: some View {
        MainCabView(gotoSettings: $isOn)
        //            .frame(width: 300, height: 300)
        //            .background(Color.gray.opacity(0.2)) // helps see layout
    }
}
