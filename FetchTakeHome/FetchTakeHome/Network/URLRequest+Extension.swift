//
//  URLRequest+Extension.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 1/30/25.
//
import Foundation

extension URLRequest {
    
    enum URLRequestError: Error {
        case invalidURL
        case failedToCreateURL
    }
   
    init(url: URL,
         cachePolicy: URLRequest.CachePolicy,
         timeoutInterval: TimeInterval,
         headers:[String: String]?,
         requestType: RequestType,
         parameters: [String: Any]?) throws {
        
        self = URLRequest(url: url,
                          cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy,
                          timeoutInterval: timeoutInterval )
    
        self.httpMethod = requestType.rawValue
    
        if let headerFields = headers {
            for (key, value) in headerFields {
                self.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let parametersDictionary = parameters,
           !parametersDictionary.isEmpty {
            
            guard var urlComponents = URLComponents(string: url.absoluteString) else {
                throw URLRequestError.invalidURL
            }
            
            let queryItems = parametersDictionary.urlQueryItems()
            urlComponents.queryItems = queryItems
            
            guard let finalURL = urlComponents.url else {
                throw URLRequestError.failedToCreateURL
            }
            self.url = finalURL
        }
    }
}
