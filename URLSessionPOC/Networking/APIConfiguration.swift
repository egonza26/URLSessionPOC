//
//  APIConfiguration.swift
//  AlamofirePOC
//
//  Created by Ernesto Gonzalez on 5/1/19.
//  Copyright © 2019 Ernesto Gonzalez. All rights reserved.
//

import Foundation

typealias Parameters = [String: Any]

enum HTTPMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}

enum NetworkLayerError: Error {
    case invalidURL
}

protocol APIConfiguration {
    var headers: String { get }
    var baseURL: String { get }
    var httpMethod: HTTPMethod { get }
    var requestPath: String { get }
    var queryItems: [URLQueryItem]? { get }
    var parameters: Parameters? { get }
}

extension APIConfiguration {
    
    var headers: String {
        // Authorization token can go here
        return ""
    }
    
    var baseURL: String {
        return AppConfiguration.shared.apiURL ?? ""
    }
    
    func buildRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL) else { throw NetworkLayerError.invalidURL }
        
        var urlRequest: URLRequest!
        
        if let queryItems = queryItems, var urlComponents = URLComponents(string: url.absoluteString) {
            urlComponents.path = requestPath
            urlComponents.queryItems = queryItems
            urlRequest = URLRequest(url: url)
        } else {
            urlRequest = URLRequest(url: url.appendingPathComponent(requestPath))
        }
        
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if !headers.isEmpty {
            urlRequest.addValue(headers, forHTTPHeaderField: "<Token form OAuth could go here for example>")
        }
        
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        
        return urlRequest
    }
}
