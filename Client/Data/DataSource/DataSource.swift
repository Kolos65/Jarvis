//
//  DataSource.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 15..
//

import Foundation

protocol DataSource {
    func response<Response: DataSourceResponse>(ofType type: Response.Type, from data: Data?, in response: URLResponse?) -> (Response?, DataSourceError?)
}

extension DataSource {
    func response<Response: Codable>(ofType type: Response.Type, from data: Data?, in response: URLResponse?) -> (Response?, DataSourceError?) {
        guard let response = response as? HTTPURLResponse else {
            return (nil, DataSourceError.default)
        }
        
        let statusCode = response.statusCode
        
        guard let data = data else {
            return (nil, DataSourceError.default)
        }
        
        guard (200...299).contains(statusCode) else {
            var error = try? JSONDecoder().decode(DataSourceError.self, from: data)
            error?.statusCode = statusCode
            return (nil, error ?? DataSourceError.default)
        }
        
        guard let result = try? JSONDecoder().decode(type, from: data) else {
            return (nil, DataSourceError.wrongFormat)
        }
        
        return (result, nil)
    }
}
