//
//  PerformRequestProtocol.swift
//  AlamofirePOC
//
//  Created by Ernesto Gonzalez on 5/1/19.
//  Copyright © 2019 Ernesto Gonzalez. All rights reserved.
//

import Foundation

protocol PerformRequestProtocol {
    func performRequest<T: Decodable>(route: APIConfiguration, completion: @escaping (_ data: T?, _ error: Error?) -> Void)
}

extension PerformRequestProtocol {
    
    func performRequest<T>(route: APIConfiguration, completion: @escaping (T?, Error?) -> Void) where T: Decodable {
        apiRequest(route: route) { data, error in
            do {
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                
                let decodableData = try JSONDecoder().decode(T.self, from: data)
                completion(decodableData, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    private func apiRequest(route: APIConfiguration, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: try! route.buildRequest()) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if 200..<300 ~= httpResponse.statusCode {
                    if let responseData = data {
                        completion(responseData, nil)
                    } else {
                        completion(nil, error)
                    }
                }
            } else {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}
