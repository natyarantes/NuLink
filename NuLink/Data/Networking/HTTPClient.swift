//
//  HTTPClient.swift
//  NuLink
//
//  Created by Natália Arantes on 07/10/25.
//

import Foundation

public protocol HTTPClient {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
