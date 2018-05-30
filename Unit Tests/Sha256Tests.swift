//
//  Sha256Tests.swift
//  NaiveCoinTests
//
//  Created by Ronald Mannak on 5/8/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import XCTest
@testable import NaiveSwiftCoinMacOS


class Sha256Tests: XCTestCase {
    
//    var key: Key!
    
    override func setUp() {
        
        super.setUp()
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testKnownValue1() {
        let data = "1234".data(using: .utf8)!
        let expected = "03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4"
        XCTAssertEqual(data.sha256.hexDescription, expected)
    }
    
    func testKnownValue2() {
        let data = "æøå".data(using: .utf8)!
        let expected = "6c228cdba89548a1af198f33819536422fb01b66e51f761cf2ec38d1fb4178a6"
        XCTAssertEqual(data.sha256.hexDescription, expected)
    }
    
    func testKnownValue3() {
        let data = "KfZ=Day*q4MsZ=_xRy4G_Uefk?^Ytr&2xL*RYY%VLyB_&c7R_dr&J+8A79suf=^".data(using: .utf8)!
        let expected = "b754632a872b3f5ddb0e1e24b531e35eb334ee3c2957618ac4a2ac4047ed6127"
        XCTAssertEqual(data.sha256.hexDescription, expected)
    }
    
    func testKnownValue4() {
        let data = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus eu dui in turpis ullamcorper fringilla sed interdum dui. Sed ex lectus, faucibus id libero a, malesuada ullamcorper tellus. In sodales gravida massa vel tempus. In accumsan scelerisque nisl facilisis fermentum. Praesent dapibus magna sed interdum vestibulum. Vestibulum risus tellus, dapibus in lacinia quis, vestibulum vel elit. Vestibulum ut viverra odio. Nulla facilisi. Vivamus dapibus porttitor sem vel laoreet. Vestibulum non dignissim nisi. In et tempor erat. Curabitur vulputate ante diam, a lacinia nisl placerat non. Nam et vulputate dui, vitae rutrum eros. Curabitur et massa in massa auctor tempus. Interdum et malesuada fames ac ante ipsum primis in faucibus.".data(using: .utf8)!
        let expected = "337aa1c6165565038254fe7b0ad5788626b56102ded936fb042f2da658c27cdd"
        XCTAssertEqual(data.sha256.hexDescription, expected)
    }
    
    func testKnownValue5() {
        let data = "0".data(using: .utf8)!
        let expected = "5feceb66ffc86f38d952786c6d696c79c2dbc239dd4e91b46729d73a27fb57e9"
        XCTAssertEqual(data.sha256.hexDescription, expected)
    }
    
    func testEmpty() {
        let data = Data()
        let expected = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        XCTAssertEqual(data.sha256.hexDescription, expected)
    }
}

//"1234" == "03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4"

//emtpy
