//
//  NuPrimaryButtonStyle.swift
//  NuLink
//
//  Created by Natália Arantes on 02/10/25.
//

import SwiftUI

public struct NuPrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? DS.Accent.pressed : DS.Accent.primary)
            .cornerRadius(DSMetrics.radiusM)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
            .accessibilityAddTraits(.isButton)
    }
}
