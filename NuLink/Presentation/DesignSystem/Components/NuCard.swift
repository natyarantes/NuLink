//
//  NuCard.swift
//  NuLink
//
//  Created by Natália Arantes on 02/10/25.
//

import SwiftUI

public struct NuCard<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        content
            .padding(.vertical, DSMetrics.paddingM)
            .padding(.horizontal, DSMetrics.paddingL)
            .background(DS.Bg.card)
            .cornerRadius(DSMetrics.radiusM)
            .shadow(color: .black.opacity(DSMetrics.shadowOpacity),
                    radius: DSMetrics.shadowRadius, x: 0, y: 2)
    }
}
