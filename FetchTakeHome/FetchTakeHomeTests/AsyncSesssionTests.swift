//
//  AsyncSesssionTests.swift
//  FetchTakeHomeTests
//
//  Created by Donald Largen on 1/30/25.
//

import XCTest
@testable import FetchTakeHome

final class AsyncSesssionTests: XCTestCase {

    struct GetResult: Codable {
        let args: [String: String]
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGet () async throws {
        let sessionConfig = AsyncSession.SessionConfiguration(scheme: "http",
                                                              host: "httpbin.org",
                                                              headers: nil,
                                                              timeout: 60)
        
        let asyncSession = AsyncSession(sessionConfiguration: sessionConfig)
        let params = ["foo": "bar"]
        
        let getResult: GetResult = try await asyncSession.get(path: "get",
                                                              parameters: params)
        
        guard getResult.args["foo"] == "bar" else {
            XCTFail()
            return
        }
    }
    
    func testDownloadImageData() async throws {
        let sessionConfig = AsyncSession.SessionConfiguration(scheme: "http",
                                                              host: "httpbin.org",
                                                              headers: nil,
                                                              timeout: 60)
        
        let asynSession = AsyncSession(sessionConfiguration: sessionConfig)
        var complete: Double? = nil
        let data = try await asynSession.download("/image/jpeg",
                                                  parameters: nil) {bytesWritten,
                                                                    totalBytesWritten,
                                                                    totalBytesExpectedToWrite,
                                                                    percentComplete in
            complete = percentComplete
        }
        
        guard let percentCompleted = complete, percentCompleted == 100 else {
            XCTFail()
            return
        }
        
        guard let _ = complete else {
            XCTFail()
            return
        }
        
        guard let _ = UIImage(data: data) else {
            XCTFail()
            return
        }
    }

}
