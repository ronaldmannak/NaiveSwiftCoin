//
//  ViewController.swift
//  NaiveCoin
//
//  Created by Ronald Mannak on 5/3/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa
import LocalAuthentication

class ViewController: NSViewController {


    override func viewDidLoad() {
        do {
            // Set up blockchain, wallet and two accounts
//            let blockchain = try Blockchain()
//            var wallet = Wallet(with: blockchain)
//            let account1 = try wallet.createAccount()
//            let account2 = try wallet.createAccount()
//
//            print("Account 1 add initial amount")
//            try account1.addInitialAmount(blockchain: blockchain)
//            print("Account 2 add initial amount")
//            try account2.addInitialAmount(blockchain: blockchain)
//            print(wallet) // both accounts should own 500 coins
//            print("Acount 1 send 200 coins")
//            try account1.send(amount: 200, to: account2.address, blockchain: blockchain)
//            print("Mine")
//            try blockchain.mine()
//            print(wallet) // 1 should have 300, 2 700
            
            /*
            // Just sign something randomly to see double check we don't get a login
            let key = try Key(with: UUID(), prompt: "test")
            let data = "1234".data(using: .utf8)!.sha256
            if try key.verify(signature: key.sign(data), digest: data) {
                print("verified")
            } else {
                print("not verified")
            }
            
            */
    
            
        } catch {
            print("======\n\(error)")
            fatalError()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

