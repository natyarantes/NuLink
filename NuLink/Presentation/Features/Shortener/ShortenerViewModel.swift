//
//  ShortenerViewModel.swift
//  NuLink
//
//  Created by Natália Arantes on 03/10/25.
//

import Foundation
import Combine

@MainActor
final class ShortenerViewModel: ObservableObject {
    
    @Published var inputText: String = ""
    @Published var isloading: Bool = false
    @Published var items: [ShortItemViewData] = []
    
    func shorten() async {
        //implementar
    }
    
    func delete(itemID: UUID) {
        items.removeAll { $0.id == itemID }
    }
    
    func clearAll() {
        items.removeAll()
    }
}

struct ShortItemViewData: Identifiable, Hashable {
    let id: UUID = UUID()
    let originalURL: String
    let shortURL: String
    let alias: String
}
