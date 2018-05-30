//
//  Blockchain+Utxos.swift
//  NaiveSwiftCoinMacOS
//
//  Created by Ronald Mannak on 5/13/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

// UTXOs
extension Blockchain {
    
    /**
     Searches for all unspent outputs belonging to address.
     - parameter address:       Address referenced in the unspent outputs.
     - parameter block:         If true, outputs in the blockchain that are
                                referenced by transaction inputs in the queue
                                will be considerend spent. Default is true.
     - returns:                 an array of tupples containting output and a
                                new input that refers to the output.
     */
    public func utxos(for address: Address, block: Bool = true) -> [(TxOutput, TxInput)] {
        
        var result = [(TxOutput, TxInput)]()
        
        // 1.   Find spent outputs in queue
        let spentOutputsInQueue = block == true ? self.transactionQueue.flatMap({ $0.inputs }).map({ self.fetchOutput(referencedBy: $0) }).filter({ $0.to == address }) : [TxOutput]()
        
        // 2.   Loop through all blocks
        for (blockIndex, block) in longestChain.enumerated() {
            
            // 2.   Loop through all transactions in each block
            for (txIndex, tx) in block.transactions.enumerated() {
                
                // 3.   Create an array of utxos. Outputs.to must match address,
                //      spentOutputsInQueue should not contain output, and the output
                //      should not be referenced to by any input (the output is spend if it is).
                let utxos = tx.outputs.filter({
                    $0.to == address && spentOutputsInQueue.contains($0) == false && searchInput(referencing: $0.sha256, startAtBlock: blockIndex) == nil
                })
                
                // 4. Append utxos and referencing inputs to result
                result.append(contentsOf: utxos.map{ ($0, TxInput(blockIndex: blockIndex, txIndex: txIndex, txOutputHash: $0.sha256)) })
                
                print("block \(blockIndex) found utxo of \(utxos)")
            }
        }
        
        // 7.   Return outputs or nil if empty
        return result
    }
    
    /**
     Usually you don't want to create transactions that use outputs that are
     already claimed by transactions in the queue. transactionsInQueue: finds
     these.
     - parameter sender:        Address of sender of transactions.
     - returns:                 Array of transactions in the queue created by sender.
    */
    public func transactionsInQueue(sender: Address) -> [Transaction] {
        return transactionQueue.filter { $0.sender == sender }
    }
    
    /**
     Searches in all transactions in the queue for outputs belonging to address.
     The outputs in the queue are per definition unspent.
     - parameter to:            The address the unspent outputs belong to.
     - returns:                 Array of unspent outputs in the queue belonging to address
     */
    public func utxosInQueue(to: Address) -> [TxOutput] {
        return outputs(to: to, in: transactionQueue)
    }
    
    /**
     Searches all transactions for spent and unspent outputs belonging to address.
     - parameter to:            The address the outputs belong to.
     - returns:                 Array of outputs in the queue belonging to address
     */
    public func outputs(to: Address, in transactions: [Transaction]) -> [TxOutput] {
        return transactions.flatMap{ $0.outputs }.filter{ $0.to == to }
    }
    
    /**
     Fetch spent output referenced by input from the blockchain.
     - parameter input:         Input referencing a spent output
     - returns:                 The output referenced by input. If the output cannot be found, it returns nil
     */
    public func fetchOutput(referencedBy input: TxInput) -> TxOutput {
        return longestChain[input.blockIndex].transactions[input.txIndex].outputs.filter { $0.sha256 == input.txOutputHash }.first!
    }
    
    
    /**
     Searches for the input in the blockchain that references outputHash.
     If no input was found, the output is unspent and searchInput:: returns nil.
     - parameter outputHash:    The hash of the output to be searched for
     - parameter startAtBlock:  The first block to be searched
     - returns:                 The input that references outputHash, or nil if output is unspent.
     */
    public func searchInput(referencing outputHash: Sha256Hash, startAtBlock start: Int = 0) -> TxInput? {
        for index in start ..< count {
            for transaction in self[index].transactions {
                for input in transaction.inputs {
                    if input.txOutputHash == outputHash { return input }
                }
            }
        }
        return nil
    }
    
    /**
     Searches the transaction queue for the input that references outputHash.
     - parameter outputHash:    The hash of the output to be searched for
     - returns:                 True if an input referencing the output is in the queue
    */
    public func inputIsInQueue(referencing outputHash: Sha256Hash) -> Bool {
        for transaction in transactionQueue {
            for input in transaction.inputs {
                if input.txOutputHash == outputHash { return true }
            }
        }
        return false
    }
    
    /**
     Returns the balance of address. The balance is
     the total amount of unspent transactions in the
     blockchain belonging to address.
     - parameter address:       Address of the account.
     - returns:                 The balance of address.
     */
    public func balance(of address: Address) -> Amount {
        return balance(of: utxos(for: address).map{ $0.0 })
    }
    
    /**
     Returns the total balance of all provided uxtos
     - parameter of:            The uxtos whos balance needs to be calculated.
     - returns:                 The total amount of all utxos provided.
     */
    public func balance(of utxos: [TxOutput]) -> Amount {
        var amount: uint64 = 0
        for utxo in utxos {
            print(utxo)
            amount = amount + utxo.amount
        }
        print("total: \(amount)")
        return amount
        return utxos.reduce(0, { $0 + $1.amount })
    }
}
