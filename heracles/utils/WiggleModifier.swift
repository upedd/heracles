//
//  WiggleModifier.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 15/04/2025.
//


import SwiftUI

extension View {
    @ViewBuilder func wiggling(isEnabled: Bool = true) -> some View {
        if isEnabled {
          modifier(WiggleModifier())
        } else {
          self
        }
    }
}

struct WiggleModifier: ViewModifier {
    @State private var isWiggling = false
    
    private static func randomize(interval: TimeInterval, withVariance variance: Double) -> TimeInterval {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random
    }
    
    private let rotateAnimation = Animation
        .easeInOut(
            duration: WiggleModifier.randomize(
                interval: 0.14,
                withVariance: 0.025
            )
        )
        .repeatForever(autoreverses: true)
    
    private let bounceAnimation = Animation
        .easeInOut(
            duration: WiggleModifier.randomize(
                interval: 0.18,
                withVariance: 0.025
            )
        )
        .repeatForever(autoreverses: true)
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isWiggling ? 4.0 : 0))
            .animation(rotateAnimation)
            .offset(x: 0, y: isWiggling ? 4.0 : 0)
            .animation(bounceAnimation)
            .onAppear() { isWiggling.toggle() }
    }
}
