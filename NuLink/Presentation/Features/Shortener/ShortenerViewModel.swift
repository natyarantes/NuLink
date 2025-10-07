//
//  ShortenerViewModel.swift
//  NuLink
//
//  Created by Natália Arantes on 03/10/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class ShortenerViewModel: ObservableObject {
    @Published var inputURL: String = ""
    @Published var isLoading: Bool = false
    @Published var shortURL: String?
    @Published var originalURL: String?
    @Published var errorMessage: String?
    @Published var items: [ShortLink] = []

    private let repo: URLShorteningRepository

    init(repo: URLShorteningRepository) {
        self.repo = repo
    }

    func shorten() {
        errorMessage = nil

        guard let url = URL(string: inputURL.trimmingCharacters(in: .whitespacesAndNewlines)),
              url.scheme != nil else {
            errorMessage = "URL inválida. Inclua https://"
            return
        }

        isLoading = true

        Task {
            defer { isLoading = false }
            do {
                let link = try await repo.shorten(url: url)
                withAnimation {
                    items.insert(link, at: 0)
                }
                inputURL = ""
                errorMessage = nil

            } catch let NetworkError.requestFailed(status, body) {
                errorMessage = "Falha \(status). \(body ?? "Sem detalhes.")"
            } catch let NetworkError.decoding(err) {
                errorMessage = "Erro ao processar a resposta: \(err.localizedDescription)"
            } catch {
                errorMessage = "Erro de rede: \(error.localizedDescription)"
            }
        }
    }


    func reset() {
        errorMessage = nil
        inputURL = ""
        isLoading = false
        withAnimation { items.removeAll() }
    }
}

