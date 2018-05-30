//
//  TransactionTests.swift
//  NaiveCoinTests
//
//  Created by Ronald Mannak on 5/8/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import XCTest
@testable import NaiveSwiftCoinMacOS


class TransactionTests: XCTestCase {
    
    var validTransaction: Transaction!
    var alteredTransaction: Transaction!
    var genesis: Transaction!
    var senderAddress: String!
    
    override func setUp() {
        super.setUp()
        do {
            let sender = try Key(with: UUID())
            senderAddress = try sender.exportKey().hexDescription
            
            // Set transaction 1
            validTransaction = try createValidTransaction(from: sender)

            // Set transaction 2
            // Emulate a transaction that was altered after it was signed
            alteredTransaction = try createAlteredTransaction(from: sender)
            
            // Set genesis
            let utxo = TxOutput(to: Data(), amount: 500)
            genesis = try Transaction(output: utxo)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTransaction1() {
        do {
            XCTAssertTrue(try validTransaction.isUnaltered())
            
            let sha = try JSONEncoder().encode(validTransaction).sha256
            XCTAssertEqual(sha, validTransaction.sha256)
            XCTAssertNotEqual(sha, alteredTransaction.sha256)
            
            let key = try Key(from: senderAddress)
            XCTAssertTrue(try key.verify(signature: validTransaction.signature, digest: validTransaction.id))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testTransaction2() {
        do {
            let sha = try JSONEncoder().encode(alteredTransaction).sha256
            XCTAssertEqual(sha, alteredTransaction.sha256)
            XCTAssertNotEqual(sha, validTransaction.sha256)
            XCTAssertEqual(alteredTransaction.outputs[0], TxOutput(to: Data(), amount: 200, id: "1234"))
            XCTAssertEqual(alteredTransaction.outputs[1], TxOutput(to: Data(), amount: 10, id: "1234"))
            
            let key = try Key(from: senderAddress)
            XCTAssertThrowsError(try key.verify(signature: alteredTransaction.signature, digest: alteredTransaction.id))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSerialization1() {
        do {
            let original = validTransaction
            let json = try JSONEncoder().encode(original)
            
            let restored = try JSONDecoder().decode(Transaction.self, from: json)
            XCTAssertEqual(original, restored)
            XCTAssertNotEqual(alteredTransaction, restored)
            XCTAssertTrue(try restored.isUnaltered())
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSerialization2() {
        do {
            let original = alteredTransaction
            let json = try JSONEncoder().encode(original)

            let restored = try JSONDecoder().decode(Transaction.self, from: json)
            XCTAssertEqual(original, restored)
            XCTAssertNotEqual(validTransaction, restored)
            XCTAssertThrowsError(try restored.isUnaltered())
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGenesis() {
        XCTAssertTrue(genesis.isGenesisTransaction)        
    }
}
