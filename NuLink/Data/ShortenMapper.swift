//
//  ShortenMapper.swift
//  NuLink
//
//  Created by Natália Arantes on 07/10/25.
//

import Foundation

enum ShortenMapper {
    static func toDomain(_ dto: ShortenResponseDTO) -> ShortLink {
        let original = URL(string: dto.links.original)?.absoluteString ?? dto.links.original
        let short = URL(string: dto.links.short)?.absoluteString ?? dto.links.short
        
        return ShortLink(alias: dto.alias,
                         original: original,
                         short: short)
    }
}


