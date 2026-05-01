//
//  CabooseView.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/27/26.
//

import SwiftUI

struct GridInputRow: View {
    let value: UInt8
    @Binding var inputText: String

    var body: some View {
        GridRow {
            Text(String(value))
                .frame(width: 45, height: 35)
                .font(.system(size: 18)).bold()
                .gridColumnAlignment(.trailing)

            TextField(String(value), text: $inputText)
                .padding(2)
                .frame(width: 42, height: 35)
                .border(.black)
                .font(.system(size: 18)).bold()
                .keyboardType(.numberPad)
        }
    }
}

struct CabooseView: View {
    @Binding var isOn: Bool
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State var showHelp = false
    @State private var forwardInput = ""
    @State private var neutralInput = ""
    @State private var reverseInput = ""
    @State private var throttleOffInput = ""
    @State private var throttleMaxInput = ""

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
                Text("Servo Settings")
                    .font(Font.system(size: 10))
                    .bold()
                    .position(x: gw * 0.45, y: gh * 0.222)
                Text("Current   New")
                    .font(Font.system(size: 10))
                    .bold()
                    .position(x: gw * 0.45, y: gh * 0.38)
                VStack(alignment: .leading, spacing: 15) {
                    Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 1
                    ) {
                        GridInputRow(value: forwardVal, inputText: $forwardInput)
                        GridInputRow(value: neutralVal, inputText: $neutralInput)
                        GridInputRow(value: reverseVal, inputText: $reverseInput)
                    }
                }
                .position(x: gw * 0.44, y: gh * 0.3)
                Image("electricalbox2")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.35)
                    .position(x: gw * 0.84, y: gh * 0.52)
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.white)
                    .frame(width: 79, height: 138)
                    .opacity(0.7)
                    .position(x: gw * 0.75, y: gh * 0.515)
                Text("Servo Settings")
                    .font(Font.system(size: 10))
                    .bold()
                    .position(x: gw * 0.75, y: gh * 0.437)
                Text("Current   New")
                    .font(Font.system(size: 10))
                    .bold()
                    .position(x: gw * 0.75, y: gh * 0.595)
                Button {
                    // Simply flip the boolean state
                    isOn.toggle()
                } label: {
                    Image("smallbutton")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.1)
                        .position(x: gw * 0.4, y: gh * 0.6)
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
        .ignoresSafeArea(.keyboard)
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
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
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
