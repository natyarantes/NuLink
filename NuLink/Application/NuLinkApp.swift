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
    
    @StateObject private var vm: ShortenerViewModel
    
    init() {
        let httpClient = URLSessionHTTPClient()
        let api = URLShortenerAPI(client: httpClient)
        let repo = RemoteURLShorteningRepository(api: api)
        
        _vm = StateObject(wrappedValue: ShortenerViewModel(repo: repo))
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ShortenerView(vm: vm)
            }
        }
    }
}
