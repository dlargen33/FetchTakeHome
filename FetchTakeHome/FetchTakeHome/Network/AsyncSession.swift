//
//  AsyncSession.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 1/30/25.
//

import Foundation

typealias AsyncSessionProgress = (_ bytesWritten: Int64,
                                  _ totalBytesWritten: Int64,
                                  _ totalBytesExpectedToWrite: Int64,
                                  _ percentComplete: Double?) -> Void

/*
 Main network class.  Used to execute Get requests and the provides the ability to Download binary data.
 Other verbs can be added, Put, Patch, Delete.
 
 Class utilizes Swift Concurrency.  Specifically the async api exposed by URLSession. 
 */
class AsyncSession: NSObject {
    
    enum SessionError: Error {
        case invalidResponseType
        case unknownHTTPStatusCode
        case unauthorized
    }
    
    struct SessionConfiguration {
        var scheme: String
        var host: String
        var headers: [String: String]?
        var timeout: Double?
        var decodingStrategy: JSONDecoder.KeyDecodingStrategy
        
        init(scheme: String,
             host: String,
             headers: [String: String]?,
             timeout: Double?,
             decodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) {
            self.scheme = scheme
            self.host = host
            self.headers = headers
            self.timeout = timeout
            self.decodingStrategy = decodingStrategy
        }
    }
    
    private let sessionConfiguration: AsyncSession.SessionConfiguration
    private lazy var urlSession: URLSession = {
        return URLSession(configuration: urlSessionConfiguration,
                          delegate: self,
                          delegateQueue: nil)
    }()
    
    
    var progressHandler: AsyncSessionProgress?
    var unauthorizedStatusCodes: [HTTPStatusCode] = [.unauthorized, .forbidden]
    var urlSessionConfiguration: URLSessionConfiguration
    
    init (sessionConfiguration: AsyncSession.SessionConfiguration ) {
        self.sessionConfiguration = sessionConfiguration
        self.urlSessionConfiguration = URLSessionConfiguration.default
        super.init()
    }
    
    /// Performs an asynchronous HTTP GET request and decodes the response into a specified Codable type.
    ///
    /// - Parameters:
    ///   - path: The API endpoint path for the GET request.
    ///   - parameters: Optional query parameters to include in the request.
    ///   - dateFormatters: Optional array of `DateFormatter` objects for handling date decoding.
    /// - Returns: A decoded object of type `Output`, conforming to `Codable`.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    func get<Output: Codable>(path: String,
                              parameters: [String: Any]?,
                              dateFormatters: [DateFormatter]? = nil) async throws -> Output {
        let request = try self.setupRequest(path: path,
                                            requestType: .get,
                                            parameters: parameters)
        
        let (data, urlResponse) = try await self.urlSession.data(for: request, delegate: self)
        
        try validateResponse(urlResponse: urlResponse)
        let result: Output = try self.handleResponse(data: data,
                                                     urlResponse: urlResponse,
                                                     dateFormatters: dateFormatters)
        return result
    }
    
    /// Downloads data from the specified path with optional parameters and progress tracking.
    ///
    /// - Parameters:
    ///   - path: The URL path to download data from.
    ///   - parameters: Optional query parameters to include in the request.
    ///   - progress: An optional progress handler that provides updates during the download.
    /// - Returns: The downloaded data as a `Data` object.
    /// - Throws: An error if the download fails.
    func download (path: String,
                   parameters: [String: Any]? = nil,
                   progress: AsyncSessionProgress? = nil) async throws -> Data {
        progressHandler = progress
        let requestType = RequestType.get
        let request = try self.setupRequest(path: path,
                                            requestType: requestType,
                                            parameters: nil)
         
        let (asyncBytes, urlResponse) = try await self.urlSession.bytes(for: request)
        
        let httpResponse = try validateResponse(urlResponse: urlResponse)
        let expectedLength = (httpResponse.expectedContentLength)
        var bytesWritten: Int64 = 0
        var data = Data()
        data.reserveCapacity(Int(expectedLength))

        for try await byte in asyncBytes {
            data.append(byte)
            if let progress = self.progressHandler {
                bytesWritten += 1
                let percentComplete = (Double(bytesWritten) / Double(expectedLength)) * 100.0
                self.notifyProgress(progressHandler: progress,
                                    bytesWritten: bytesWritten,
                                    totalBytesExpectedToWrite: expectedLength,
                                    percentComplete: percentComplete )
            }
        }

        progressHandler = nil
        return data
    }
}

extension AsyncSession {
    private func composedURL(_ path: String) -> URL? {
        if let precomposed = URL(string: path),
           precomposed.scheme != nil,
           precomposed.host != nil {
            return precomposed
        }

        guard let scheme = sessionConfiguration.scheme.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let host = sessionConfiguration.host.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }

        let baseURLString = "\(scheme)://\(host)"
        guard let baseURL = URL(string: baseURLString) else {
            return nil
        }

        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        
        return baseURL.appendingPathComponent(encodedPath)
    }
    
    private func setupRequest(path: String,
                              requestType: RequestType,
                              parameters: [String:Any]?) throws -> URLRequest {
        
        
        guard let url = composedURL(path) else {
            throw URLError(
                .badURL,
                userInfo: [NSURLErrorFailingURLStringErrorKey: path])
        }
        
        let request = try URLRequest(url: url,
                                     cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy,
                                     timeoutInterval: sessionConfiguration.timeout ?? 60.0,
                                     headers: sessionConfiguration.headers,
                                     requestType: requestType,
                                     parameters: parameters)
        
       return request
    }
    
    @discardableResult
    private func validateResponse(urlResponse: URLResponse) throws -> HTTPURLResponse {
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw SessionError.unauthorized
        }
        
        guard let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) else {
            throw SessionError.unknownHTTPStatusCode
        }
        
        if statusCode.responseType != .success {
            if unauthorizedStatusCodes.contains(statusCode) {
                throw SessionError.unauthorized
            }
            //HttpStatusCode is an error, thus it can be thrown.
            throw statusCode
        }
        
        return httpResponse
    }
    
    private func handleResponse<Output: Decodable>(data: Data,
                                                   urlResponse: URLResponse,
                                                   dateFormatters: [DateFormatter]? = nil)  throws -> Output {
        try validateResponse(urlResponse: urlResponse)
        let response = Response(data: data, response: urlResponse)
        let decoded = try response.decoded(Output.self,
                                           dateFormatters: dateFormatters,
                                           keyDecodingStrategy: sessionConfiguration.decodingStrategy)
            
        
        return decoded
    }
    
    private func notifyProgress(progressHandler: AsyncSessionProgress,
                                bytesWritten: Int64,
                                totalBytesExpectedToWrite: Int64,
                                percentComplete: Double) {
    
        guard let progressHandler = self.progressHandler else { return }
        DispatchQueue.main.async {
            progressHandler(bytesWritten,
                            bytesWritten,
                            totalBytesExpectedToWrite,
                            percentComplete)
        }
    }
}


extension AsyncSession : URLSessionDelegate {}

extension AsyncSession: URLSessionDataDelegate {}

extension AsyncSession:  URLSessionTaskDelegate {}

extension AsyncSession: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
            //no op.  Async methods handle this
    }
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
            
        if let progressHandler = self.progressHandler {
            var percentComplete: Double?
            if totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown {
                percentComplete = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            }
            
            DispatchQueue.main.async {
                progressHandler(bytesWritten,
                                totalBytesWritten,
                                totalBytesExpectedToWrite,
                                percentComplete)
            }
        }
    }
}
