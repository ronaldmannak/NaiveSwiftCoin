//
//  Wallet.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/23/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

/**
 A wallet contains one or multiple accounts. Usually there is only one wallet
 per device, with multiple accounts.
 */
public struct Wallet {
    
    /// The blockchain
    public var blockchain: Blockchain
    
    /// Array of the accounts in this wallet
    public private (set) var accounts = [Account]()
    
    /**
     Wallet initializer
     - parameter blockchain:    Blockchain the wallet is tied to
     */
    public init(with blockchain: Blockchain) {
        self.blockchain = blockchain
    }
}

extension Wallet {
    
    /**
     Creates a new account and adds the new account to the accounts property.
     - parameter name:      Human readable name of the account, given by the
                            account's owner. When nil, a UUID will be created.
     - returns:             the new account.
     - throws:              Apple encryption error if keypair creation was unsuccessful
     */
    public mutating func createAccount(named name: String? = nil) throws -> Account {
        let account = try Account(named: name ?? "Account \(accounts.count + 1)")
        accounts.append(account)
        return account
    }
}

// Accounts
extension Wallet {

    /**
     Returns the balance of an account.
     - parameter account:   The account queried
     - returns:             the balance of the account
     */
    public func balance(of account: Account? = nil) -> UInt64 {
        if let account = account {
            return account.balance(blockchain: blockchain)
        }
        var balance: UInt64 = 0
        for account in accounts {
            balance = balance + account.balance(blockchain: blockchain)
        }
        return balance
    }
    
    /**
     Sends coins to an address on the blockchain.
     - parameter amount:    The amount being sent.
     - parameter from:      The sender. The user must have access to the
                            private key of this account.
     - parameter to:        The address of the recipient in string format.
     */
    public func send(amount: Amount, from account: Account, to addressString: String) throws {
        let recipient = try Key(from: addressString)
        try account.send(amount: amount, to: try recipient.exportKey(), blockchain: blockchain)        
    }
    
    /**
     Fetches the account struct with provided name.
     - parameter named:     The name of the account being searched for
     - returns:             The account or nil if no account was found
     */
    public func account(named: String) -> Account? {
        let account = accounts.filter({ $0.name == named })
        guard account.isEmpty == false else { return nil }
        return account.first!
    }
}

extension Wallet: CustomStringConvertible {
    public var description: String {
        return accounts.map{ $0.description + " : \($0.balance(blockchain: blockchain))\n" }.joined()
    }
}
