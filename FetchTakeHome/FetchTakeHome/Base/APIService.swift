//
//  FetchService.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 1/30/25.
//

///
/// Defines what a APIService looks like.  Provides default implementation to create a AsyncSession
///
protocol APIService {
    func createSession(host: String) -> AsyncSession
}

extension APIService {
    func createSession(host: String) -> AsyncSession {
        let sessionConfig = AsyncSession.SessionConfiguration(
            scheme: "https",
            host: host,
            headers: nil,
            timeout: 60,
            decodingStrategy: .convertFromSnakeCase)
        return AsyncSession(sessionConfiguration: sessionConfig)
    }
}


