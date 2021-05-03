//
//  EventsRequest.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 17..
//

struct EventsRequest: DataSourceRequest {
    var from: Int?
    var to: Int?
    var limit: Int?
    var offset: Int?
    
    init(from: Int? = nil, to: Int? = nil, limit: Int? = nil, offset: Int? = nil) {
        self.from = from
        self.to = to
        self.limit = limit
        self.offset = offset
    }
}
