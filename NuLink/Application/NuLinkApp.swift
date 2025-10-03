//
//  NuLinkApp.swift
//  NuLink
//
//  Created by Natália Arantes on 02/10/25.
//

import SwiftUI
import CoreData

@main
struct NuLinkApp: App {
    
    @StateObject private var vm = ShortenerViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ShortenerView(vm: vm)
            }
        }
    }
}
