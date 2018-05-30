//
//  Account.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/23/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

/**
 Account
 */
public struct Account {

    /// User defined, human readable name of the account
    public var name:            String
    
    /// Public key in Data format
    public let address:         Address
    
    /// Human readable public key address
    public var publicKey:       String {
        return address.hexDescription
    }
    
    /// Key management
    fileprivate let key:        Key
    
    /// Id label to use, store and retrieve the public and private keys
    public let uuid: UUID
    
    /**
     Initializes a new account. Invoked by Wallet.
     - parameter name:          Human readable name of the account
                                provided by the owner. If no name is
                                provided, a UUID will be used. The
                                name can be changed later
     */
    public init(named name: String) throws {
        self.name =             name
        uuid =                  UUID()
        key =                   try Key(with: uuid, prompt: "Sign transaction")
        address =               try key.exportKey()
    }
}

// Balance
extension Account {
    
    /**
     Returns the spendable amount of address
     - parameter blockchain: The blockchain address is part of
     - returns: the total amount of all utxos in the blockchain minus any
     inputs in the queue that reference an output owned by address
     */
    func balance(blockchain: Blockchain) -> Amount {
        return blockchain.balance(of: address)
    }
}

// Transactions
extension Account {
    
    /**
     Send coins to an address
     - parameter amount: the amount of coins being sent
     - parameter to: the address of the recipient of the coins
     - parameter blockchain: the blockchain both sender and receiver are part of
     */
    public func send(amount: Amount, to: Address, blockchain: Blockchain) throws {
        
        // 1.   Fetch all unspent outputs for this account.
        let utxos = blockchain.utxos(for: self.address)
        
        // 2.   Select the utxos we're going to use
        //      For how to optimize selecting UTXOs, see
        //      https://medium.com/@lopp/the-challenges-of-optimizing-unspent-output-selection-a3e5d05d13ef
        var totalAmount: Amount = 0
        var inputs = [TxInput]()
        for (output, input) in utxos {
            inputs.append(input)
            totalAmount = totalAmount + output.amount
            if totalAmount >= amount { break } // The funds in the added utxos are enough to cover the payment
        }
        
        // 3.   Check if balance (=sum of all utxos) is sufficient
        guard totalAmount >= amount else { throw CoinError.insufficientFunds(amount, totalAmount) }
        
        // 4.   Create output to sender
        var outputs = [TxOutput]()
        outputs.append(TxOutput(to: to, amount: amount))
        
        // 5.   Create change output to self
        let change = TxOutput(to: address, amount: totalAmount - amount)
        outputs.append(change)
        
        // 6.   Create transaction
        let tx = try Transaction(sender: address, inputs: inputs, outputs: outputs) { try self.key.sign($0) }
        
        // 7.   Add transaction to the blockchain queue
        try blockchain.queue(tx)
    }
    
    /**
     Request a payment from another account.
     - parameter amount:            The amount requested
     - parameter from:              The address the amount is requested from
     - parameter reason:            Optional human readable description of the
                                    reason (e.g. "Rent July")
     */
    public func request(amount: Amount, from address: String, reason: String? = nil) {
        // TODO:
    }
    
//    func transactionHistory(blockchain: Blockchain) -> [Transaction] {
//        
//    }
    
    /**
     Prefills the account with infinitely reusable coins from
     the genesis block, so people using the demo don't have to mine
     before they can spend coins.
     - parameter amount:            The amount of the prefill, up to 500 coins.
                                    500 is the hardcoded amount of coins in the
                                    the genesis block that any account can copy.
     */
    func addInitialAmount(amount: Amount = 500, blockchain: Blockchain) throws {
        
        // 1.   Fetch genesis block
        let genesisBlock = blockchain.longestChain[0]
        let genesisUtxo = genesisBlock.transactions.first!.outputs.first!
        let genesisAmount = genesisUtxo.amount
        
        // 2.   Sanity check
        guard genesisAmount >= amount else { throw CoinError.insufficientFunds(genesisAmount, amount)}
        
        // 3.   Create outputs
        let output: [TxOutput]
        if genesisAmount == amount {
            output = [TxOutput(to: address, amount: amount)]
        } else {
            let change = genesisAmount - amount
            output = [TxOutput(to: address, amount: amount), TxOutput(to: Data(), amount: change)]
        }
        let genesisReference = TxInput(blockIndex: 0, txIndex: 0, txOutputHash: Data())
        
        // 4.   Create a prefill transaction
        let prefill = try Transaction(sender: address, inputs: [genesisReference], outputs: output) { try self.key.sign($0) }
        
        // 5.   Add prefill transaction to the queue
        try blockchain.queue(prefill)
        
        // 6.   Mine queue so that account is instantly
        //      credited with the prefill
        try blockchain.mine()
    }

}

extension Account: CustomStringConvertible {    
    public var description: String {
        return "\(name) (...\(address.hexDescription.suffix(4))"
    }
}
