//
//  Error.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 13..
//

struct DataSourceError: Codable {
    static let `default` = DataSourceError(message: "Something went wrong, please try again later!")
    static let wrongFormat = DataSourceError(message: "Could not parse data returned from the server!")
    
    var message: String
    var statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case message = "error"
    }
}
