//
//  OutputTests.swift
//  NaiveCoinTests
//
//  Created by Ronald Mannak on 5/8/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import XCTest
@testable import NaiveSwiftCoinMacOS


class OutputTests: XCTestCase {
    
    var output1: TxOutput!
    var output2: TxOutput!
    
    override func setUp() {
        output1 = TxOutput(to: Data(), amount: 0, id: "1234")
        output2 = TxOutput(to: "04e02eb1bc268cbc04ed8fc19df331a759500cf97c63d50e587aa65f079ff5f4009769363cebba7cc28572bdee57b040d5250991836816b4bc4d7aaca4d996be2b".data(using: .utf8)!, amount: 200, id: "1234")
        super.setUp()
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testKnownOutput1() {
        do {
            let json = try JSONEncoder().encode(output1)
            
            XCTAssertEqual(output1.sha256.hexDescription, "b42ddb299a550b2f4bf203e697276a88d2f684e4c6e0d13986708619cc78b558")
            XCTAssertEqual(json.sha256.hexDescription, "b42ddb299a550b2f4bf203e697276a88d2f684e4c6e0d13986708619cc78b558")
            XCTAssertNotEqual(output1.sha256.hexDescription, output2.sha256.hexDescription)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testKnownOutput2() {
        do {
            let json = try JSONEncoder().encode(output2)
        
            XCTAssertEqual(output2.sha256.hexDescription, "db93c3f5a5f8b742e216e6e7dc8337cc9e82b5bdf8203770d270a15cbe5a8d5e")
            XCTAssertEqual(json.sha256.hexDescription, "db93c3f5a5f8b742e216e6e7dc8337cc9e82b5bdf8203770d270a15cbe5a8d5e")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSerialization1() {
        do {
            let original = output1
            let json = try JSONEncoder().encode(original)
            
            let restored = try JSONDecoder().decode(TxOutput.self, from: json)
            XCTAssertEqual(original, restored)
            XCTAssertNotEqual(output2, restored)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSerialization2() {
        do {
            let original = output2
            let json = try JSONEncoder().encode(original)
            
            let restored = try JSONDecoder().decode(TxOutput.self, from: json)
            XCTAssertEqual(original, restored)
            XCTAssertNotEqual(output1, restored)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
