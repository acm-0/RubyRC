//
//  LeverState.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/16/26.
//


import SwiftUI

enum LeverState: Int, CaseIterable {
    case reverse = 0
    case neutral = 1
    case forward = 2
}



struct ThreePositionLever: View {
    @Binding var state: LeverState   // 👈 controlled from parent
    @State private var angle: Double = 0

    let positions: [Double] = [-45, 0, 45]

    var body: some View {
        GeometryReader { geo in
            let pivot = CGPoint(
                x: geo.size.width / 2,
                y: geo.size.height * 0.75
            )

            Image("lever")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .rotationEffect(.degrees(angle), anchor: .bottom)
                .position(pivot)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let dx = value.location.x - pivot.x
                            let dy = value.location.y - pivot.y

                            let radians = atan2(dy, dx)
                            let degrees = radians * 180 / .pi
                            let adjusted = degrees + 90

                            angle = min(max(adjusted, -60), 60)
                        }
                        .onEnded { _ in
                            snapToNearest()
                        }
                )
                .onTapGesture {
                    cyclePosition()
                }
                .onAppear {
                    syncAngleWithState()
                }
                .onChange(of: state) {
                    syncAngleWithState()
                }
        }
    }
    
    func syncAngleWithState() {
        let index = state.rawValue
        guard index < positions.count else { return }

        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            angle = positions[index]
        }
    }

    func snapToNearest() {
        guard let nearestIndex = positions.indices.min(by: {
            abs(positions[$0] - angle) < abs(positions[$1] - angle)
        }) else { return }

        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            angle = positions[nearestIndex]
            state = LeverState(rawValue: nearestIndex) ?? .neutral
        }
    }
    
    func cyclePosition() {
        let nextIndex = (state.rawValue + 1) % positions.count

        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            angle = positions[nextIndex]
            state = LeverState(rawValue: nextIndex) ?? .neutral
        }
    }
}

#Preview {
    @Previewable @State var leverState = LeverState.reverse
    ThreePositionLever(state: $leverState)
}
