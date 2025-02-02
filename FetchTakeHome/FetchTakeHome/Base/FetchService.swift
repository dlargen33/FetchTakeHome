//
//  FetchService.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 1/30/25.
//

/*
 Defines what a FetchService looks like.  Provides default implementation to create a configuration need
 for the Network Session.
 */
protocol FetchService  {
    func createSessionConfiguration() -> AsyncSession.SessionConfiguration
    var session: AsyncSession { get }
}

extension FetchService {
    
    var session: AsyncSession {
        return AsyncSession(sessionConfiguration: createSessionConfiguration())
    }
    
    func createSessionConfiguration() -> AsyncSession.SessionConfiguration {
        let sessionConfig = AsyncSession.SessionConfiguration(
            scheme: "https",
            host: "d3jbb8n5wk0qxi.cloudfront.net",
            headers: nil,
            timeout: 60,
            decodingStrategy: .convertFromSnakeCase)
        return sessionConfig
    }
    

}
