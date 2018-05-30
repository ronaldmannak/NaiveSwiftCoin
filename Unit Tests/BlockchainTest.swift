//
//  BlockchainTest.swift
//  NaiveCoinTests
//
//  Created by Ronald Mannak on 5/11/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import XCTest
@testable import NaiveSwiftCoinMacOS

class BlockchainTests: XCTestCase {
    
    var blockchain: Blockchain!
    var wallet1: Wallet!
    var wallet2: Wallet!
    var totalAmount: Int64!
    
    override func setUp() {
        super.setUp()

        do {
            blockchain = try Blockchain(autoScheduleMining: false)
            wallet1 = Wallet(with: blockchain)
            let account1 = try wallet1.createAccount()
            let account2 = try wallet1.createAccount()
            
            wallet2 = Wallet(with: blockchain)
            let account3 = try wallet2.createAccount(named: "First Account")
            let account4 = try wallet2.createAccount(named: "Second Account")
            
            try account1.addInitialAmount(amount: 500, blockchain: blockchain)
            try account2.addInitialAmount(amount: 400, blockchain: blockchain)
            try account3.addInitialAmount(amount: 250, blockchain: blockchain)
            try account4.addInitialAmount(amount: 100, blockchain: blockchain)
            
            totalAmount = 500 + 400 + 250 + 100
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testWallet1() {
        XCTAssertTrue(wallet1.balance(of: wallet1.accounts.first!) == 500)
        XCTAssertTrue(wallet1.balance(of: wallet1.accounts.last!) == 400)
    }

    func testWallet2() {
        XCTAssertTrue(wallet2.balance(of: wallet2.accounts.first!) == 250)
        XCTAssertTrue(wallet2.balance(of: wallet2.accounts.last!) == 100)
    }

    func testSimpleTransfers() {
        do {
            try wallet1.send(amount: 87, from: wallet1.accounts.first!, to: wallet1.accounts.last!.publicKey)
            try blockchain.mine()
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.first!) == 500 - 87)
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.last!) == 400 + 87)
            XCTAssertTrue(wallet1.balance() + wallet2.balance() == totalAmount)

            // Test insufficient funds
            XCTAssertThrowsError(try wallet1.send(amount: 490, from: wallet1.accounts.first!, to: wallet1.accounts.last!.publicKey))

            // Test order within one block
            try wallet1.send(amount: 487, from: wallet1.accounts.last!, to: wallet1.accounts.first!.publicKey)
            try blockchain.mine() // TODO: We cannot have two transactions from the same in one block. Should send take the queue into account?
            try wallet1.send(amount: 900, from: wallet1.accounts.first!, to: wallet1.accounts.last!.publicKey)
            try blockchain.mine()

            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.first!) == 0)
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.last!) == 900)
            XCTAssertTrue(wallet1.balance() + wallet2.balance() == totalAmount)

        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testIntermediateTransfers() {
        
    }
    
    func testInterWalletTransfers() {
        do {
            // Block 5
            try wallet1.send(amount: 87, from: wallet1.accounts.first!, to: wallet2.accounts.last!.publicKey)
            try blockchain.mine()
            XCTAssertTrue(wallet1.balance() + wallet2.balance() == totalAmount)
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.first!) == 500 - 87)
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.last!) == 400)
            XCTAssertTrue(wallet2.balance(of: wallet2.accounts.first!) == 250)
            XCTAssertTrue(wallet2.balance(of: wallet2.accounts.last!) == 100 + 87)
            
            // Block 6
            try wallet1.send(amount: 100, from: wallet1.accounts.last!, to: wallet2.accounts.last!.publicKey)
            try blockchain.mine()
            XCTAssertTrue(wallet1.balance() + wallet2.balance() == totalAmount)
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.first!) == 500 - 87)
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.last!) == 400 - 100)
            XCTAssertTrue(wallet2.balance(of: wallet2.accounts.first!) == 250)
            XCTAssertTrue(wallet2.balance(of: wallet2.accounts.last!) == 100 + 87 + 100)
            
            // Block 7
            try wallet2.send(amount: 200, from: wallet2.accounts.first!, to: wallet1.accounts.last!.publicKey)
            try blockchain.mine()
            XCTAssertTrue(wallet1.balance() + wallet2.balance() == totalAmount)
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.first!) == 500 - 87)
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.last!) == 400 - 100 + 200)
            XCTAssertTrue(wallet2.balance(of: wallet2.accounts.first!) == 250 - 200)
            XCTAssertTrue(wallet2.balance(of: wallet2.accounts.last!) == 100 + 87 + 100)
            
            // Block 8
            try wallet2.send(amount: 70, from: wallet2.accounts.last!, to: wallet1.accounts.last!.publicKey)
            try blockchain.mine()
            XCTAssertTrue(wallet1.balance() + wallet2.balance() == totalAmount, "Wrong total amount: \(wallet1.balance() + wallet2.balance()) instead of \(totalAmount!)")
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.first!) == 500 - 87)
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.last!) == 400 - 100 + 200 + 70)
            XCTAssertTrue(wallet2.balance(of: wallet2.accounts.first!) == 250 - 200)
            XCTAssertTrue(wallet2.balance(of: wallet2.accounts.last!) == 100 + 87 + 100 - 70)
            print(wallet2.balance(of: wallet2.accounts.last!))
            
            // Block 9
            try wallet2.send(amount: 10, from: wallet2.accounts.last!, to: wallet1.accounts.first!.publicKey)
            try blockchain.mine()
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.first!) == 500 - 87 + 10)
            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.last!) == 400 - 100 + 200 + 70)
            XCTAssertTrue(wallet2.balance(of: wallet2.accounts.first!) == 250 - 200)
            XCTAssertTrue(wallet2.balance(of: wallet2.accounts.last!) == 100 + 87 + 100 - 70 - 10)
            XCTAssertTrue(wallet1.balance() + wallet2.balance() == totalAmount)

            
//            // Test insufficient funds
//            XCTAssertThrowsError(try wallet1.send(amount: 490, from: wallet1.accounts.first!, to: wallet1.accounts.last!.publicKey))
//
//            // Test order within one block
//            try wallet1.send(amount: 487, from: wallet1.accounts.last!, to: wallet1.accounts.first!.publicKey)
//            try blockchain.mine() // TODO: We cannot have two transactions from the same in one block. Should send take the queue into account?
//            try wallet1.send(amount: 900, from: wallet1.accounts.first!, to: wallet1.accounts.last!.publicKey)
//            try blockchain.mine()
//
//            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.first!) == 0)
//            XCTAssertTrue(wallet1.balance(of: wallet1.accounts.last!) == 900)
//            XCTAssertTrue(wallet1.balance() == 900)
            
            //            print("balance:")
            //            print(wallet1.balance(of: wallet1.accounts.first!))
            //            print(wallet1.balance(of: wallet1.accounts.last!))
            //            print("-----")
            //            print(blockchain)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testEdgeCases() {
        do {
            
            // Sending from an account that is not owned by wallet
//            XCTAssertThrowsError(try wallet2.send(amount: 70, from: wallet1.accounts.last!, to: wallet2.accounts.last!.publicKey))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // two blockchains, send from one to another
}
