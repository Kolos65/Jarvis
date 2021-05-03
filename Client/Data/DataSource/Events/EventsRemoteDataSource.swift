//
//  EventsRemoteDataSource.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 17..
//

import Foundation

class EventsRemoteDataSource: EventsDataSource {
    private enum Constants {
        static let events = "events"
        static let fromQuery = "from"
        static let toQuery = "to"
        static let limitQuery = "limit"
        static let offsetQuerry = "offset"
        static let authorization = "Authorization"
    }
    
    func getEvents(request: EventsRequest, token: String, completion: @escaping (EventsResponse?, DataSourceError?) -> Void) {
        var url = Environment.host.appendingPathComponent(Constants.events)
        if let from = request.from {
            url = url.appendingQueryItem(Constants.fromQuery, value: String(from))
        }
        if let to = request.to {
            url = url.appendingQueryItem(Constants.toQuery, value: String(to))
        }
        if let limit = request.limit {
            url = url.appendingQueryItem(Constants.limitQuery, value: String(limit))
        }
        if let offset = request.offset {
            url = url.appendingQueryItem(Constants.offsetQuerry, value: String(offset))
        }
        var req = URLRequest(url: url)
        req.setValue(token, forHTTPHeaderField: Constants.authorization)
            
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            let (res, err) = self.response(ofType: EventsResponse.self, from: data, in: response)
            DispatchQueue.main.async { completion(res, err) }
        }
        task.resume()
    }
    
}

