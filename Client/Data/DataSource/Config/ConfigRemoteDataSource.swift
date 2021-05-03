//
//  ConfigRemoteDataSource.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 17..
//

import Foundation

class ConfigRemoteDataSource: ConfigDataSource {
    private enum Constants {
        static let reset = "reset"
        static let detector = "detector"
        static let recognizer = "recognizer"
        
        static let post = "POST"
        static let contentType = "Content-Type"
        static let authorization = "Authorization"
        static let json = "application/json"
    }
    
    func resetMotionDetector(token: String, completion: @escaping (ResetResponse?, DataSourceError?) -> Void) {
        let url = Environment.host
            .appendingPathComponent(Constants.detector)
            .appendingPathComponent(Constants.reset)
        var req = URLRequest(url: url)
        req.setValue(token, forHTTPHeaderField: Constants.authorization)
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            let (res, err) = self.response(ofType: ResetResponse.self, from: data, in: response)
            DispatchQueue.main.async { completion(res, err) }
        }
        task.resume()
    }
    
    func setMotionDetector(request: DetectorRequest, token: String, completion: @escaping (DetectorResponse?, DataSourceError?) -> Void) {
        let url = Environment.host.appendingPathComponent(Constants.detector)
        var req = URLRequest(url: url)
        req.httpMethod = Constants.post
        req.httpBody = try? JSONEncoder().encode(request)
        req.setValue(Constants.json, forHTTPHeaderField: Constants.contentType)
        req.setValue(token, forHTTPHeaderField: Constants.authorization)
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            let (res, err) = self.response(ofType: DetectorResponse.self, from: data, in: response)
            DispatchQueue.main.async { completion(res, err) }
        }
        task.resume()
    }
    
    func setFaceRecognition(request: RecognizerRequest, token: String, completion: @escaping (RecognizerResponse?, DataSourceError?) -> Void) {
        let url = Environment.host.appendingPathComponent(Constants.recognizer)
        var req = URLRequest(url: url)
        req.httpMethod = Constants.post
        req.httpBody = try? JSONEncoder().encode(request)
        req.setValue(Constants.json, forHTTPHeaderField: Constants.contentType)
        req.setValue(token, forHTTPHeaderField: Constants.authorization)
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            let (res, err) = self.response(ofType: RecognizerResponse.self, from: data, in: response)
            DispatchQueue.main.async { completion(res, err) }
        }
        task.resume()
    }
    
    func getMotionDetector(token: String, completion: @escaping (DetectorResponse?, DataSourceError?) -> Void) {
        let url = Environment.host.appendingPathComponent(Constants.detector)
        var req = URLRequest(url: url)
        req.setValue(token, forHTTPHeaderField: Constants.authorization)
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            let (res, err) = self.response(ofType: DetectorResponse.self, from: data, in: response)
            DispatchQueue.main.async { completion(res, err) }
        }
        task.resume()
    }
    
    func getFaceRecognition(token: String, completion: @escaping (RecognizerResponse?, DataSourceError?) -> Void) {
        let url = Environment.host.appendingPathComponent(Constants.recognizer)
        var req = URLRequest(url: url)
        req.setValue(token, forHTTPHeaderField: Constants.authorization)
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            let (res, err) = self.response(ofType: RecognizerResponse.self, from: data, in: response)
            DispatchQueue.main.async { completion(res, err) }
        }
        task.resume()
    }
}

