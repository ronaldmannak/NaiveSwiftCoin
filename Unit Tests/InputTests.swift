//
//  InputTests.swift
//  NaiveCoinTests
//
//  Created by Ronald Mannak on 5/8/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import XCTest
@testable import NaiveSwiftCoinMacOS


class InputTests: XCTestCase {
    
    let input1 = TxInput(blockIndex: 0, txIndex: 0, txOutputHash: Data())
    let input2 = TxInput(blockIndex: 1, txIndex: 1, txOutputHash: "5678".sha256)
    let input1Hash = "955f495b585a7a745716dadace20f3fc125a842437d6f5268723c83839abc435"
    let input2Hash = "1adc56192c44dcedb2214c73be4a03886bb219496e44aca38a97f79740ea86d4"
        
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testKnownInput1() {
        do {
            let json = try JSONEncoder().encode(input1).sha256.hexDescription
            
            XCTAssertEqual(json, input1Hash)
            XCTAssertNotEqual(json, input2Hash)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testKnownInput2() {
        do {
            let json = try JSONEncoder().encode(input2).sha256.hexDescription
            
            XCTAssertEqual(json, input2Hash)
            XCTAssertNotEqual(json, input1Hash)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSerialization1() {
        do {
            let original = input1
            let json = try JSONEncoder().encode(original)
            
            let restored = try JSONDecoder().decode(TxInput.self, from: json)
            XCTAssertEqual(original, restored)
            XCTAssertNotEqual(input2, restored)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSerialization2() {
        do {
            let original = input2
            let json = try JSONEncoder().encode(original)
            
            let restored = try JSONDecoder().decode(TxInput.self, from: json)
            XCTAssertEqual(original, restored)
            XCTAssertNotEqual(input1, restored)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
