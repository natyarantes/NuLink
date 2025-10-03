//
//  NuFieldStyle.swift
//  NuLink
//
//  Created by Natália Arantes on 02/10/25.
//

import SwiftUI

public struct NuField: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .padding(14)
            .background(DS.Bg.card)
            .cornerRadius(DSMetrics.radiusM)
    }
}
public extension View {
    func nuField() -> some View {
        modifier(NuField())
    }
}
