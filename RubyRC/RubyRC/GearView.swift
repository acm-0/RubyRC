//
//  GearView.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/24/26.
//
import SwiftUI

struct GearView: View {
    @Binding var isOn: Bool

    var body: some View {
        GeometryReader { geometry in
            let gw = geometry.size.width
            let gh = geometry.size.height

            Image("gear")
                .resizable()
                .scaledToFit()
                .scaleEffect(0.4)
                .position(x: gw * 0.5, y: gh * 0.5)
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
    }
}

#Preview {
    GearPreviewWrapper()
}

struct GearPreviewWrapper: View {
    @State private var isOn = false

    var body: some View {
        GearView(isOn: $isOn)
        //            .frame(width: 300, height: 300)
        //            .background(Color.gray.opacity(0.2)) // helps see layout
    }
}
