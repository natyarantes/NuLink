//
//  UITestURLShorteningRepository.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

#if DEBUG
import Foundation

enum UITestScenario: String {
    case success
    case requestFailed
    case decoding
    case delayedSuccess
}

final class UITestURLShorteningRepository: URLShorteningRepository {
    private let scenario: UITestScenario
    init(scenario: UITestScenario) { self.scenario = scenario }

    func shorten(url: URL) async throws -> ShortLink {
        switch scenario {
        case .success:
            return ShortLink(alias: "a1",
                             original: url.absoluteString,
                             short: "https://sho.rt/a1")
        case .delayedSuccess:
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3s
            return ShortLink(alias: "d1",
                             original: url.absoluteString,
                             short: "https://sho.rt/d1")
        case .requestFailed:
            throw NetworkError.requestFailed(status: 500, body: "oops")
        case .decoding:
            throw NetworkError.decoding(NSError(domain: "decode", code: 0))
        }
    }
}
#endif
