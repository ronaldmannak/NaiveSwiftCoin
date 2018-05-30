//
//  Blockchain.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/18/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

/**
 Blockchain is the storage for the blockchain, including forks,
 and the transactionQueue containing transactions that are
 waiting to be mined.
 */
public class Blockchain {
    
    /// Contains all blocks, including invalidated branches
    public private(set) var archive: [Block]
    
    /// Contains a single longest chain.
    public private(set) var longestChain: [Block]
    
    /// Queue of transactions waiting to be mined into blocks
    public private(set) var transactionQueue: [Transaction]
    
    // If true, the blockchain will mine a new block automatically
    // Set to false for unit tests
    public private(set) var autoScheduleMining: Bool
    
    /**
     Creates a new blockchain with new genesis block
     - parameter autoScheduleMining: if true, Blockchain will automatically
     mine at regular intervals. Default is true. Set to false for unit tests.
     */
    public init(autoScheduleMining: Bool = true) {
        let genesis = Block()
        archive = [genesis]
        longestChain = [genesis]
        transactionQueue = [Transaction]()
        self.autoScheduleMining = autoScheduleMining
    }
}

// Difficulty
extension Blockchain {
    
    /// A block will be generated every 10 seconds
    private static let blockGenerationInterval: TimeInterval = 10 // seconds
    
    /// The difficulty will be increased every 10 blocks
    private static let difficultyAdjustmentInterval: Int = 10 // blocks
    
    /// Returns curent difficulty. Difficulty equals the number
    /// of zeros needed to end the hash with in order to be a valid block
    public var difficulty: Int {
        let latest = self.last!
        if latest.index == 0 {
            return latest.difficulty + 1
        } else if latest.index % Blockchain.difficultyAdjustmentInterval == 0 {
            // Adjust difficulty
            return adjustDifficulty()
        } else {
            return latest.difficulty
        }
    }
    
    
    /**
     Difficulty adjustment algorithm
     - returns:     The number of trailing zeros a block hash needs to be valid
     */
    private func adjustDifficulty() -> Int {
        let previousAdjustmentIndex = longestChain.count - Blockchain.difficultyAdjustmentInterval
        guard previousAdjustmentIndex > 0 else { fatalError() }
        let previousAdjustmentBlock = longestChain[previousAdjustmentIndex]
        let timeExpected = Blockchain.blockGenerationInterval * TimeInterval(Blockchain.difficultyAdjustmentInterval)
        let timeTaken = longestChain.last!.timestamp - previousAdjustmentBlock.timestamp
        if timeTaken < timeExpected / 2 {
            return previousAdjustmentBlock.difficulty + 1
        } else if timeTaken > timeExpected * 2 {
            return abs(previousAdjustmentBlock.difficulty - 1)
        } else {
            return previousAdjustmentBlock.difficulty
        }
    }
}

// Queue and Mining
extension Blockchain {
    
    /**
     Adds a transaction to the queue. Invoke mine to
     mine the transactions in the queue into a block
     - parameter transaction:   The transaction to be queued.
     - throws:                  nothing really. TODO:
     */
    public func queue(_ transaction: Transaction) throws {
        
        // 1.   Validate signature of transaction
        guard try transaction.isUnaltered() == true else {
            throw CoinError.invalidTransactions([transaction])
        }
        
        // 2.   Validate referenced utxos in transaction
        // TODO:
        for utxo in transaction.inputs {
            //            _ = try output(referencedBy: utxo.output)
        }
        
        // 2.   Add transaction to the queue
        transactionQueue.append(transaction)
        
        // 2.   Broadcast queue to other nodes
        // TODO: network broadcast
    }
    

    /**
     Mines a new block with the transactions in the transaction queue,
     to be added to the blockchain
     - throws:
     */
    public func mine() throws {
        
        // Sanity check. If queue is empty, quit
        guard transactionQueue.isEmpty == false else { return }
        
        // 1.   Validate that the transactions are unaltered
        transactionQueue = try transactionQueue.filter{ try $0.isUnaltered() == true }
        
        // TODO:
        // 2.   Validate transactions don't double spend
        //      If any transaction input refers to a spent output,
        //      the transaction will be removed from the queue
        //        for transaction in transactionQueue {
        //            for input in transaction.inputs {
        //                if input(referencing: input.output) != nil {
        //
        //                }
        //                for output in input.output
        //            }
        //        }
        //
        //
        //        transactionQueue = transactionQueue.filter{
        //            $0.inputs.map(<#T##transform: (TxIn) throws -> T##(TxIn) throws -> T#>)
        //
        //            input(referencing: <#T##TxOut#>) }
        
        //      or multiple transactions in the current queue refer
        //      to the same unspent transaction, only the first transaction
        //      will remain in the queue.
        
        
        var usedUtxos = [TxOutput]()
        
        let lastBlock = last!
        var block: Block? = nil
        while block == nil {
            block = try Block.mine(transactions: transactionQueue, previous: lastBlock, difficulty: difficulty)
        }
        
        // Append new block to blockchain
        archive.append(block!)
        updateChain()
        
        // Clear Queue
        transactionQueue = [Transaction]()
    }
}

// Update the chain
extension Blockchain {

    /// Copies the longest chain in the longestChain property
    public func updateChain() {
        longestChain = archive
        
        
        
        // TODO: check for forks and choose longest chain
        // TODO: Add cumulative dificulty https://lhartikk.github.io/jekyll/update/2017/07/13/chapter2.html
        // TODO: Change underlying data structure of archive to a tree?
        /*
         const replaceChain = (newBlocks: Block[]) => {
         if (isValidChain(newBlocks) && newBlocks.length > getBlockchain().length) {
         console.log('Received blockchain is valid. Replacing current blockchain with received blockchain');
         blockchain = newBlocks;
         broadcastLatest();
         } else {
         console.log('Received blockchain invalid');
         }
         };
         */
        // send notification
    }
}
