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
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
    
    func testHandleEmptuRecipes() async throws {
        let recipeService = RecipeService(configuration:
                                            TestConfiguration(route: "recipes-empty.json"))
        let list = try await recipeService.getRecipes()
        XCTAssert(list.count == 0 )
    }
}
