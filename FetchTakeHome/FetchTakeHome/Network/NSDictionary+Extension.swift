//
//  NSDictionary+Extension.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 1/30/25.
//

import Foundation

extension Dictionary where Key: ExpressibleByStringLiteral {
    
    func urlQueryItems() -> [URLQueryItem] {
        let items = reduce([]) { current, keyValuePair ->[URLQueryItem] in
            current + [URLQueryItem(name:"\(keyValuePair.key)", value: "\(keyValuePair.value)")]
        }
        return items
    }
    
}
