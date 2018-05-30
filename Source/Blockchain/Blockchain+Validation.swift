//
//  Blockchain+Validation.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/27/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

// Block
extension Blockchain {
    
    //    public mutating func append(data: String) -> Block? {
    //        guard let block = Block(data: data, previous: last!, difficulty: difficulty), block.isValid else {
    //            return nil
    //        }
    //        archive.append(block)
    //        updateChain()
    //        return block
    //    }
    //
    public var isValid: Bool {
        var expectedIndex = 0
        var previousHash = Data()
        for (index, block) in longestChain.enumerated() {
            if index == 0 {
                // First block is always genesis block
                guard block.isValidGenesis == true else { return false }
                guard block.index == expectedIndex else { return false }
                
                previousHash = block.sha256
                expectedIndex = block.index + 1
            } else {
                guard block.isValid == true else { return false }
                guard block.index == expectedIndex else { return false }
                guard block.previousHash == previousHash else { return false }
                
                previousHash = block.sha256
                expectedIndex = expectedIndex + 1
            }
        }
        return true
    }
}

// Transactions
extension Blockchain {
    
    func isValid(_ transaction: Transaction, publicKey: Address) throws -> Bool {
        
        // 1. Verify transaction integrity
        guard try transaction.isUnaltered() == true else { return false }
        guard transaction.sender == publicKey else { return false }
        
        // 1. Verify inputs
        var inputAmount: Int = 0
        
        for input in transaction.inputs {
            
            // a. Verify inputs are unaltered
            //let isValid = crypto.verify(input.signature, integer: input.output.hashValue) // , publicKey: transaction.sender
            //guard isValid == true else { return false }
            
            // b. Verify transaction and output exists
            //            fetch output and transaction
            
            // c. Verify output is owned by sender
            
            // d. Verify transaction is unaltered
            
            // e. Verify output amount is equal to input
            
            // f. Verify current input is only reference to output in transaction to prevent double spend
            
            // g. Verify current input is only reference to output in the blockchain to prevent double spend
            
            // h. Verify transaction of output is valid (that triggers many validations, and is probably unnecessary)
            
            //            inputAmount = inputAmount + output.amount
        }
        
        // 2. Verify output
        var outputAmount: Int = 0
        
        for output in transaction.outputs {
            //            outputAmount = outputAmount + output.amount
        }
        
        // Can't spend more than the inputs combined
        guard inputAmount >= outputAmount else { return false }
        
        // Verify transactions haven't been altered
        //        let unsignedTxIn = Set(self.txIn.map{ $0.unsignedTx })
        //        let calculatedId: Int = Transaction.hashedInputsOutputs(unsignedTxIn, txOut)
        //        guard calculatedId == id else { return false }
        //
        //        // Verify inputs were signed by sender
        //        for input in txIn {
        //            guard input.signature == input.signature else { return false } // TODO:
        //        }
        //
        //        // Check if inputs refer to valid output
        //        for input in txIn {
        //            let referencedUnspentTxOut = unspentOutput(input.txOutId, input.txOutIndex)
        //            let referencedAddress = referencedUnspentTxOut.to
        //            guard referencedUnspentTxOut == input.txOutId else { return false }
        //        }
        
        return true
    }
    
    // TODO:
    public func validateTransactionsInBlockchain(_ transactions: [Transaction]) -> Bool {
        return true
    }
}
