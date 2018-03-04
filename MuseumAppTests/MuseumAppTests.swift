//
//  MuseumAppTests.swift
//  MuseumAppTests
//
//  Created by Orsolya Lukacs-Kisbandi on 16/02/2018.
//  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.
//

import XCTest
@testable import MuseumApp

class MuseumAppTests: XCTestCase {
    
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    // Painting class test
    // Confirm that the Painting initializer returns a Painting object when passed valid parameters.
    func testMealInitializationSucceeds() {
        // Zero rating
        let zeroRatingMeal = Painting.init(name: "Zero", photo: nil, rating: 0)
        XCTAssertNotNil(zeroRatingMeal)
        
        // Highest positive rating
        let positiveRatingMeal = Painting.init(name: "Positive", photo: nil, rating: 5)
        XCTAssertNotNil(positiveRatingMeal)
    }
    
    // test fail case - negative rating
    func testMealInitializationFails(){
        let negativeRating = Painting.init(name: "negative", photo: nil, rating: -1)
        XCTAssertNil(negativeRating)
        
    }
    
    // test empty string
    func testEmptyString(){
        let emptyString = Painting.init(name: "", photo: nil, rating: 0)
        XCTAssertNil(emptyString)
    }
}
