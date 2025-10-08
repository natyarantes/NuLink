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
#if DEBUG
        let env = ProcessInfo.processInfo.environment
        if env["UI_TESTING"] == "1",
           let raw = env["UI_TEST_SCENARIO"],
           let scenario = UITestScenario(rawValue: raw) {
            let repo: URLShorteningRepository = UITestURLShorteningRepository(scenario: scenario)
            _vm = StateObject(wrappedValue: ShortenerViewModel(repo: repo))
            return
        }
#endif
        
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
