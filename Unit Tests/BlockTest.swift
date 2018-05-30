//
//  BlockTest.swift
//  NaiveCoinTests
//
//  Created by Ronald Mannak on 5/10/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import XCTest
@testable import NaiveSwiftCoinMacOS

class BlockTests: XCTestCase {
    
    var key: Key!
    var senderAddress: String!
    
    var genesis: Block!
    var validBlock: Block!
    
    override func setUp() {
        super.setUp()
        
        do {
            key = try Key(with: UUID())
            senderAddress = try key.exportKey().hexDescription
            
            // Create genesis block
            genesis = try Block()
            
            // Create valid block
            validBlock = try createValidBlock(from: key, previous: genesis)

        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGenesis() {
        XCTAssertTrue(genesis.isValid)
        XCTAssertTrue(genesis.isValidGenesis)
    }
    
    func testValidBlock() {
        XCTAssertTrue(validBlock.isValid)
        XCTAssertFalse(validBlock.isValidGenesis)
    }
    
    func testAlteredBlock() {
        // Mining a block with an altered transaction should throw an
        // "EC signature verification failed, no match" error
        XCTAssertThrowsError(try createAlteredBlock(from: key, previous: validBlock))
    }
}
