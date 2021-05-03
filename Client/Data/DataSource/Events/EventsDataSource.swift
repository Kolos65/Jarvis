//
//  EventsDataSource.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 17..
//

protocol EventsDataSource: DataSource {
    func getEvents(request: EventsRequest, token: String, completion: @escaping (EventsResponse?, DataSourceError?) -> Void)
}
