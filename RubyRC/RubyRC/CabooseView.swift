//
//  CabooseView.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/27/26.
//

import SwiftUI

struct CabooseView: View {
    @Binding var isOn: Bool
    @State private var forwardInput = ""
    @State private var neutralInput = ""
    @State private var reverseInput = ""

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
                Image("electricalbox")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.35)
                    .position(x: gw * 0.36, y: gh * 0.3)
                VStack(alignment: .leading, spacing: 15) {
                    Grid(
                        alignment: .leading,
                        horizontalSpacing: 0,
                        verticalSpacing: 1
                    ) {
                        // --- Forward Row ---
                        GridRow {
                            TextField("0-180", text: $forwardInput)
                                .padding(8)
                                .frame(width: 80)
                                .background(Color(.white))
                                .opacity(0.7)
                                .border(.black)
                                //                                .cornerRadius(5)
                                //                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.5)))
                                .keyboardType(.numberPad)
                        }
                        // --- Neutral Row ---
                        GridRow {
                            TextField("0-180", text: $neutralInput)
                                .padding(8)
                                .frame(width: 80)
                                .background(Color(.systemBackground))
                                .opacity(0.7)
                                .border(.black)
                                .keyboardType(.numberPad)
                        }
                        // --- Reverse Row ---
                        GridRow {

                            TextField("0-180", text: $reverseInput)
                                .padding(8)
                                .frame(width: 80)
                                .background(Color(.systemBackground))
                                .opacity(0.7)
                                .border(.black)
                                .keyboardType(.numberPad)
                        }
                    }
                    .position(x: gw * 0.45, y: gh * 0.3)
                }
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
}

#Preview {
    CaboosePreviewWrapper()
}

struct CaboosePreviewWrapper: View {
    @State private var isOn = false

    var body: some View {
        CabooseView(isOn: $isOn)
        //            .frame(width: 300, height: 300)
        //            .background(Color.gray.opacity(0.2)) // helps see layout
    }
}
