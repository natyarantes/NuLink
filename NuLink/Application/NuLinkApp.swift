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
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
