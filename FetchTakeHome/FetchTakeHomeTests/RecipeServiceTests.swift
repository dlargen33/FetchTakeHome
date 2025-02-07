//
//  RecipeServiceTests.swift
//  FetchTakeHomeTests
//
//  Created by Donald Largen on 2/2/25.
//

import XCTest
@testable import FetchTakeHome

final class RecipeServiceTests: XCTestCase {

    struct TestConfiguration: RecipeServiceConfiguration {
        let route: String
        
        var recipeListRoute: String {
            return route
        }
    }
    
    class TestAsyncSession: AsyncSessionProtocol {
        var sessionConfiguration: AsyncSession.SessionConfiguration
        var downloadCalled = false
        var data = Data()
        
        init(){
            sessionConfiguration = AsyncSession.SessionConfiguration(scheme: "https",
                                                                     host: "somehost",
                                                                     headers: nil,
                                                                     timeout: 60)
        }
        
        func get<Output: Codable>(path: String,
                                  parameters: [String : Any]?,
                                  dateFormatters: [DateFormatter]?) async throws -> Output {
            
            return [String: String]() as! Output
        }
        
        func download(path: String,
                      parameters: [String : Any]?,
                      progress: FetchTakeHome.AsyncSessionProgress?) async throws -> Data {
            downloadCalled = true
           return data
        }
        
        func createValidData() {
            let image = UIImage(systemName: "photo") ?? UIImage()
            data = image.pngData() ?? Data()
        }
        
        func createBadData() {
            data = Data()
        }
    }
    
    class TestImageRepository: ImageRepositoryProtocol {
        var imageData: ImageData?
        var addImageDataCalled = false
        var getImageDataCalled = false
        
        func addImageData(imageData: ImageData) async -> Bool {
            addImageDataCalled = true
            return true
        }
        
        func getImageData(referenceID: String) async -> ImageData? {
            getImageDataCalled = true
            return imageData
        }
        
        func createValidImageData(referenceID: String) {
            let image = UIImage(systemName: "photo") ?? UIImage()
            let data = image.pngData() ?? Data()
            let expire = Date().addingTimeInterval(7200)
            imageData = ImageData(referenceId: referenceID,
                                  data: data,
                                  expire: expire)
        }
        
        func createExpiredImageData(referenceID: String) {
            let image = UIImage(systemName: "photo") ?? UIImage()
            let data = image.pngData() ?? Data()
            let expire = Date().addingTimeInterval(-7200)
            imageData = ImageData(referenceId: referenceID,
                                  data: data,
                                  expire: expire)
        }
        
        func createMissingImageData() {
            imageData = nil
        }
    }
    
    func testCanGetRecipes() async throws {
        let recipeService = RecipeService()
        let list = try await recipeService.getRecipes()
        XCTAssert(list.count > 0)
    }
    
    func testHandleMalformedRecipes() async throws {
        let recipeService = RecipeService(configuration:
                                            TestConfiguration(route: "recipes-malformed.json"))
    
        do {
            _ = try await recipeService.getRecipes()
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertTrue(error is RecipeServiceError, "Expected RecipeServiceError: \(error)")
        }
    }
    
    func testHandleEmptyRecipes() async throws {
        let recipeService = RecipeService(configuration:
                                            TestConfiguration(route: "recipes-empty.json"))
        let list = try await recipeService.getRecipes()
        XCTAssert(list.count == 0 )
    }
    
    func testGetsImageFromCache() async throws {
        let testImageRepository = TestImageRepository()
        let testAsyncSession = TestAsyncSession()
        let referenceID = "0c6ca6e7-e32a-4053-b824-1dbf749910d8"
        testImageRepository.createValidImageData(referenceID: referenceID)
        
        let recipeService = RecipeService(session: testAsyncSession,
                                          imageRepository: testImageRepository)
        let recipe = Recipe(cuisine: "Malaysian",
                            name: "Apam Balik",
                            photoUrlLarge: nil,
                            photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                            sourceUrl: nil,
                            uuid: referenceID,
                            youtubeUrl: nil)
        
        let data = try await recipeService.getRecipeImage(recipe: recipe)
        XCTAssert(data.count > 0)
        XCTAssert(!testAsyncSession.downloadCalled)
    }
    
    func testImageFromCacheIsExpired() async throws {
        let testImageRepository = TestImageRepository()
        let testAsyncSession = TestAsyncSession()
        let referenceID = "0c6ca6e7-e32a-4053-b824-1dbf749910d8"
        testImageRepository.createExpiredImageData(referenceID: referenceID)
        testAsyncSession.createValidData()
        
        let recipeService = RecipeService(session: testAsyncSession,
                                          imageRepository: testImageRepository)
        let recipe = Recipe(cuisine: "Malaysian",
                            name: "Apam Balik",
                            photoUrlLarge: nil,
                            photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                            sourceUrl: nil,
                            uuid: referenceID,
                            youtubeUrl: nil)
        
        let data = try await recipeService.getRecipeImage(recipe: recipe)
        XCTAssert(data.count > 0)
        XCTAssert(testAsyncSession.downloadCalled)
        XCTAssert(testImageRepository.addImageDataCalled)
    }
    
    func testImageOnCacheMiss() async throws {
        let testImageRepository = TestImageRepository()
        let testAsyncSession = TestAsyncSession()
        let referenceID = "0c6ca6e7-e32a-4053-b824-1dbf749910d8"
        testImageRepository.createMissingImageData()
        testAsyncSession.createValidData()
        
        let recipeService = RecipeService(session: testAsyncSession,
                                          imageRepository: testImageRepository)
        let recipe = Recipe(cuisine: "Malaysian",
                            name: "Apam Balik",
                            photoUrlLarge: nil,
                            photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                            sourceUrl: nil,
                            uuid: referenceID,
                            youtubeUrl: nil)
        
        let data = try await recipeService.getRecipeImage(recipe: recipe)
        XCTAssert(data.count > 0)
        XCTAssert(testAsyncSession.downloadCalled)
        XCTAssert(testImageRepository.addImageDataCalled)
    }
    
    func testThrowWhenMissingUrl() async throws {
        let testImageRepository = TestImageRepository()
        let testAsyncSession = TestAsyncSession()
        let referenceID = "0c6ca6e7-e32a-4053-b824-1dbf749910d8"
        testImageRepository.createMissingImageData()
        
        let recipeService = RecipeService(session: testAsyncSession,
                                          imageRepository: testImageRepository)
        let recipe = Recipe(cuisine: "Malaysian",
                            name: "Apam Balik",
                            photoUrlLarge: nil,
                            photoUrlSmall: nil,
                            sourceUrl: nil,
                            uuid: referenceID,
                            youtubeUrl: nil)
        
        do {
            let _ = try await recipeService.getRecipeImage(recipe: recipe)
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertTrue(error is RecipeServiceError, "Expected RecipeServiceError: \(error)")
        }
        
        XCTAssert(!testAsyncSession.downloadCalled)
        XCTAssert(!testImageRepository.addImageDataCalled)
    }
    
    func testThrowsForBadUrl() async throws {
        let testImageRepository = TestImageRepository()
        let testAsyncSession = TestAsyncSession()
        let referenceID = "0c6ca6e7-e32a-4053-b824-1dbf749910d8"
        testImageRepository.imageData = nil
        
        let recipeService = RecipeService(session: testAsyncSession,
                                          imageRepository: testImageRepository)
        let recipe = Recipe(cuisine: "Malaysian",
                            name: "Apam Balik",
                            photoUrlLarge: nil,
                            photoUrlSmall: "this_is_not_an_url",
                            sourceUrl: nil,
                            uuid: referenceID,
                            youtubeUrl: nil)
        
        do {
            let _ = try await recipeService.getRecipeImage(recipe: recipe)
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertTrue(error is RecipeServiceError, "Expected RecipeServiceError: \(error)")
        }
        
        XCTAssert(!testAsyncSession.downloadCalled)
        XCTAssert(!testImageRepository.addImageDataCalled)
    }
    
}
