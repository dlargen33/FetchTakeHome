//
//  Response.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 1/30/25.
//

import Foundation

class Response {
    private let responseData: Data
    public let urlResponse: URLResponse
    
    init(data: Data, response: URLResponse) {
        self.urlResponse = response
        self.responseData = data
    }
    
    func decoded<T:Decodable>(_ type: T.Type,
                              dateFormatters: [DateFormatter]?,
                              keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy) throws -> T {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        
        if let formatters = dateFormatters {
            decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                guard let container = try? decoder.singleValueContainer(),
                    let text = try? container.decode(String.self) else {
                        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath,
                                                                                debugDescription: "Could not decode date text"))
                }
                
                var decodedDate: Date?
                for formatter in formatters {
                    if let date = formatter.date(from: text) {
                        decodedDate = date
                        break
                    }
                }
                guard let date = decodedDate else {
                    throw DecodingError.dataCorruptedError(in: container,
                                                           debugDescription: "Cannot decode date string \(text)")
                }
                return date
            })
        }
        
        do {
            let result = try decoder.decode(type, from: responseData)
            return result
        }
        catch {
            throw error
        }
    }
}
