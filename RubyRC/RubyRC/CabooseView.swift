//
//  CabooseView.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/27/26.
//

import SwiftUI

struct CabooseView: View {
    @Binding var isOn: Bool
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State var showHelp = false
    @State private var forwardInput = ""
    @State private var neutralInput = ""
    @State private var reverseInput = ""

    @State private var forwardVal: UInt8 = 0
    @State private var neutralVal: UInt8 = 0
    @State private var reverseVal: UInt8 = 0
    @State private var throttleOffVal: UInt8 = 0
    @State private var throttleMaxVal: UInt8 = 0

    var body: some View {
        GeometryReader { geometry in
            let gw = geometry.size.width
            let gh = geometry.size.height
            ZStack {
                /* Background */
                Image("caboose")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()  // fills entire screen
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
                LanternView(isConnected: bluetoothManager.isConnected)
                    .scaleEffect(0.8)
                    .position(x: gw * 0.745, y: gh * 0.025)
                Image("electricalbox")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.35)
                    .position(x: gw * 0.36, y: gh * 0.3)
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.white)
                    .frame(width: 79, height: 138)
                    .opacity(0.7)
                    .position(x: gw * 0.45, y: gh * 0.30)
                VStack(alignment: .leading, spacing: 15) {
                    Grid(
                        alignment: .leading,
                        horizontalSpacing: 0,
                        verticalSpacing: 1
                    ) {
                        // --- Forward Row ---
                        GridRow {
                            Text(String(forwardVal))
                                .font(Font.system(size: 25))
                                .padding(.trailing, 10)
                                .gridColumnAlignment(.trailing)
                            TextField("0-180", text: $forwardInput)
                                .padding(8)
                                .frame(width: 40, height: 35)
                                .border(.black)
                                .font(Font.system(size: 25))
                                .keyboardType(.numberPad)
                        }
                        // --- Neutral Row ---
                        GridRow {
                            Text(String(neutralVal))
                                .font(Font.system(size: 25))
                                .padding(.trailing, 10)
                                .gridColumnAlignment(.trailing)
                            TextField("0-180", text: $neutralInput)
                                .padding(8)
                                .frame(width: 40, height: 35)
                                .border(.black)
                                .font(Font.system(size: 25))
                                .keyboardType(.numberPad)
                        }
                        //                        // --- Reverse Row ---
                        GridRow {
                            Text(String(reverseVal))
                                .font(Font.system(size: 25))
                                .padding(.trailing, 10)
                                .gridColumnAlignment(.trailing)
                            TextField("0-180", text: $reverseInput)
                                .padding(8)
                                .frame(width: 40, height: 35)
                                .border(.black)
                                .font(Font.system(size: 25))
                                .keyboardType(.numberPad)
                        }
                    }
                    .position(x: gw * 0.44, y: gh * 0.3)
                }
                Image("electricalbox2")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.35)
                    .position(x: gw * 0.84, y: gh * 0.52)
                Button {
                    // Simply flip the boolean state
                    isOn.toggle()
                } label: {
                    Image("smallbutton")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.1)
                        .position(x: gw * 0.5, y: gh * 0.5)
                        .shadow(color: .red, radius: 10)
                }
                .buttonStyle(.plain)
            }
            /* Help Overlay */
            .overlay {
                if showHelp {
                    CabooseHelpOverlay()
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: bluetoothManager.servoBytes) {
            forwardVal = bluetoothManager.servoBytes[0]
            neutralVal = bluetoothManager.servoBytes[1]
            reverseVal = bluetoothManager.servoBytes[2]
            throttleOffVal = bluetoothManager.servoBytes[3]
            throttleMaxVal = bluetoothManager.servoBytes[4]
        }
        .onChange(of: bluetoothManager.isConnected) {
            if bluetoothManager.isConnected {
                GetCurrentServoDefaults()
            }
        }
    }

    func GetCurrentServoDefaults() {
        if bluetoothManager.isConnected {
            print("Launching request to read")
            bluetoothManager.GetServoDefaults()
        }
    }

}

extension CabooseView {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    CaboosePreviewWrapper()
}

struct CaboosePreviewWrapper: View {
    @State private var isOn = false

    var body: some View {
        CabooseView(isOn: $isOn)
            .environmentObject(BluetoothManager())
        //            .frame(width: 300, height: 300)
        //            .background(Color.gray.opacity(0.2)) // helps see layout
    }
}
