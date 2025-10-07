
//
//  DTO+Mapper+RemoteService.swift
//  NuLink
//
//  Created by Natália Arantes on 07/10/25.
//

import Foundation

struct ShortenResponseDTO: Decodable, Equatable {
    let alias: String
    let links: LinksDTO

    private enum CodingKeys: String, CodingKey {
        case alias
        case links = "_links"
    }
}

struct LinksDTO: Decodable, Equatable {
    let original: String
    let short: String

    private enum CodingKeys: String, CodingKey {
        case original = "self"
        case short
    }
}

