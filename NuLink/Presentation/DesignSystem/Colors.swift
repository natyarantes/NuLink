//
//  Colors.swift
//  NuLink
//
//  Created by Natália Arantes on 02/10/25.
//

import SwiftUI


public enum DSColor {
    public static let purple       = Color(hex: 0x820AD1)
    public static let purpleDark   = Color(hex: 0x5E0AA3)
    public static let purpleLight  = Color(hex: 0xB877FF)

    public static let background   = Color(UIColor.systemBackground)
    public static let surface      = Color(UIColor.secondarySystemBackground)
    public static let textPrimary  = Color(UIColor.label)
    public static let textSecondary = Color(UIColor.secondaryLabel)
}

public enum DS {
    public enum Bg {
        public static let app   = DSColor.background
        public static let card  = DSColor.surface
    }
    public enum Text {
        public static let primary   = DSColor.textPrimary
        public static let secondary = DSColor.textSecondary
        public static let accent    = DSColor.purple
    }
    public enum Accent {
        public static let primary = DSColor.purple
        public static let pressed = DSColor.purpleDark
        public static let subtle  = DSColor.purpleLight
    }
}

public extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8)  & 0xFF) / 255.0
        let b = Double(hex & 0xFF)        / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
