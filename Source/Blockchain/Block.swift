//
//  Block.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/18/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

/**
 Block data structure containing an array of transactions.
 Only the genesis block can be created using an init. All other block should be
 mined.
 Based on https://en.bitcoin.it/wiki/Protocol_documentation#block
 */
public struct Block: Codable, Equatable, Sha256Hashable {
    
    /// Internal data structure that contains the transactions, difficulty, and the nonce.
    /// Will be hashed by Block.
    public struct Message: Codable, Equatable, Sha256Hashable {
        
        /// Index of the block. Block 0 is the genesis block
        public let index: Int
        
        /// Hash of the previous block (which has with index - 1)
        public let previousHash: Sha256Hash
        
        /// Timestamp when the message was created
        public let timestamp: TimeInterval // seconds
        
        /// List of signed transactions in this block
        public let transactions: [Transaction]
        
        /// Random number to generate hash with the correct number of leading zeros as set in difficulty
        public let nonce: UInt32
        
        /// Equal to the number of zeros of the hash in binary
        public let difficulty: Int
        
        /// Computed property of the hash
        public var sha256: Sha256Hash {
            return try! JSONEncoder().encode(self).sha256
        }
    }
    
    /// Internal data structure that will be signed by Block
    public let message: Message
    
    /// Stored hashValue of the message property. Should always be equal to computed property message.hashValue
    /// If the hashses are different, the message has been altered and the block should be invalidated
    public let sha256: Sha256Hash
    
    // Convenience accessors
    public var index: Int { return message.index }
    public var previousHash: Sha256Hash { return message.previousHash }
    public var timestamp: TimeInterval { return message.timestamp }
    public var transactions: [Transaction] { return message.transactions }
    public var nonce: UInt32 { return message.nonce }
    public var difficulty: Int { return message.difficulty }
    
    /**
     Initializes a genesis block. The genesis block contains one 500 coins transaction
     that every new account can copy for demo purposes
     */
    public init() {
        let utxo = TxOutput(to: Data(), amount: 500)
        let transaction = Transaction(output: utxo)
        
        message = Message(index: 0, previousHash: Data(), timestamp: Date.timeIntervalSinceReferenceDate, transactions: [transaction], nonce: 0, difficulty: 0)
        sha256 = message.sha256
    }
    
    
    /**
     Private initializer to create a new block with a random nonce. If the nonce doesn't
     produce a valid hash, init returns nil.
     
     Use static method mine:transactions:previous:difficulty to mine a new block.
     
     - parameter transactions: Array of transactions to be included in the new block
     - parameter previous: The previous block
     - parameter difficulty: The number of ending zeros in the hash needed to validate the block. Minimum is 1.
     
     - throws: Throws an invalidTransactions error if one or more transactions aren't valid, or a Key error
     */
    private init?(transactions: [Transaction], previous: Block, difficulty: Int) throws {
        
        // 1.   Sanity check. Unless block is a genesis block (which are
        //      created using init()), the block should be mined.
        guard difficulty > 0 else { throw CoinError.miningDifficultyError(difficulty) }
        
        // 2.   Validate transactions. Checks for double spending and if sender has enough balance
        var invalidTransactions = [Transaction]()
        for transaction in transactions {
            guard try transaction.isUnaltered() == true else {
                invalidTransactions.append(transaction)
                continue
            }
        }
        guard invalidTransactions.isEmpty == true else { throw CoinError.invalidTransactions(invalidTransactions) }
        
        // 3.   Create internal data structure of Block with a random integer as nonce
        message = Message(index: previous.message.index + 1, previousHash: previous.sha256, timestamp: Date.timeIntervalSinceReferenceDate, transactions: transactions, nonce: arc4random_uniform(UInt32.max), difficulty: difficulty)
        
        // 4.   Create a binary string of the hash of the message
        //      to validate expected zeros easily
        let binaryHash = message.sha256.binaryDescription
        
        // 5.   Confirm the hash has the minimum number of most
        //      significant zeros. If not, return nil
        let expectedZeros = String(repeating: "0", count: difficulty)
        guard binaryHash.hasPrefix(expectedZeros) == true else { return nil }
        
        sha256 = message.sha256
    }
    
    
    /**
     Mines an array of signed transactions in a new block.
     Mine will not return until it has found a valid hash and should normally not be run on the main thread.
     
     - parameter transactions: Array of transactions to be included in the new block
     - parameter previous: The previous block
     - parameter difficulty: The number of ending zeros in the hash needed to validate the block. Minimum is 1.

     - Throws: Throws an invalidTransation error if a transaction is not valid
     */
    public static func mine(transactions: [Transaction], previous: Block, difficulty: Int) throws -> Block {
        
        // Loop until we find a block that contains a message that the minimum amount of trailing zeros
        while true {
            if let block = try Block(transactions: transactions, previous: previous, difficulty: difficulty) {
                return block
            }
        }
    }
}

// Computed properties
public extension Block {
    
    /**
     Checks if block is valid by validating that the stored hash
     value is equal to computed hash.
     - returns:     Returns true if block is valid.
     */
    public var isValid: Bool {
        
        // 1.   Exception for genesis block
        if index == 0 { return isValidGenesis }
        
        // 2.   Validate that every transaction is unaltered
        guard sha256 == message.sha256 else { return false }
        for transaction in message.transactions {
            do {
                guard try transaction.isUnaltered() == true else { return false }
            } catch {
                return false
            }
        }
        
        // 3.   Validate that difficulty has been met
        let expectedZeros = String(repeating: "0", count: message.difficulty)
        guard sha256.binaryDescription.hasPrefix(expectedZeros) == true else { return false }
        
        return true
    }
    
    
    /**
     Checks if block is a genesis block by validating that the stored hash value
     is equal to computed hash, index equals zero, previous hash equals zero and
     data is empty.
     - returns:     Returns true if block is a genesis block.
     */
    public var isValidGenesis: Bool {
    
        // A valid genesis is either no transaction or
        // a single transaction with free coins (for testing purposes)
        let validTransaction: Bool = {
            guard let transaction = message.transactions.first else {
                return true // message contains no transactions is valid
            }
            guard transaction.isGenesisTransaction else {
                return false
            }
            return true
        }()
        
        guard previousHash == Data(), index == 0, validTransaction == true else { return false }
        return true
    }
    
    /**
     Returns true if the timestamp is at most 1 min in the future from the time we perceive and if the timestamp is at most 1 min in the past of the previous block.
     - returns:     Returns true if timestamp is valid
     */
    public func hasValidTimestamp(previous: Block) -> Bool {
        return (previous.timestamp - 60 < timestamp) && (timestamp - 60 < Date.timeIntervalSinceReferenceDate)
    }
}

// CustomStringConvertible
extension Block: CustomStringConvertible {
    public var description: String {
        return "(index: \(message.index), previousHash: \(message.previousHash.hexDescription.suffix(4)), timestamp: \(message.timestamp), hashValue: \(sha256.hexDescription.suffix(4))), message: \n\(message.transactions)"
    }
}
