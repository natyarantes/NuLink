//
//  NetworkError.swift
//  NuLink
//
//  Created by Natália Arantes on 07/10/25.
//

enum NetworkError: Error {
    case invalidURL //endpoint malformed
    case encodingFailed(Error) //fail to convert body to json
    case requestFailed(status: Int, body: String?) //http error returned from server
    case transport(Error) //network error - no response
    case decoding(Error) //fail to decode json
}
