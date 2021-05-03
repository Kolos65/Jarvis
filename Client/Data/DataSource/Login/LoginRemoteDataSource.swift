//
//  LoginRemoteDataSource.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 13..
//

import Foundation

class LoginRemoteDataSource: LoginDataSource {
    private enum Constants {
        static let login = "login"
        static let session = "hello"
        
        static let post = "POST"
        static let contentType = "Content-Type"
        static let json = "application/json"
    }
    
    func startSession(completion: @escaping (SessionResponse?, DataSourceError?) -> Void) {
        let url = Environment.host.appendingPathComponent(Constants.session)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            let (res, err) = self.response(ofType: SessionResponse.self, from: data, in: response)
            DispatchQueue.main.async { completion(res, err) }
        }
        task.resume()
    }
    
    func login(request: LoginRequest, completion: @escaping (LoginResponse?, DataSourceError?) -> Void) {
        let url = Environment.host.appendingPathComponent(Constants.login)
        var req = URLRequest(url: url)
        req.httpMethod = Constants.post
        req.httpBody = try? JSONEncoder().encode(request)
        req.setValue(Constants.json, forHTTPHeaderField: Constants.contentType)
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            let (res, err) = self.response(ofType: LoginResponse.self, from: data, in: response)
            DispatchQueue.main.async { completion(res, err) }
        }
        task.resume()
    }
}

