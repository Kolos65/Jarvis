//
//  LoginDataSource.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 13..
//

protocol LoginDataSource: DataSource {
    func startSession(completion: @escaping (SessionResponse?, DataSourceError?) -> Void)
    func login(request: LoginRequest, completion: @escaping (LoginResponse?, DataSourceError?) -> Void)
}
