//
//  Transaction.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/20/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

/// Transactions are created and signed by the transaction's sender.
/// Transactions are then broadcasted to the miners where they will be queued
/// and be included in a next block.
/// Based on https://bitcoin.org/en/developer-guide#transactions and
public struct Transaction: Codable, Equatable {
    
    /// A hash of all inputs and outputs in this transaction (excluding signatures)
    /// The id guarantees the inputs and output in this transaction have not been altered,
    /// so long as the id is equal to the hashValue of all inputs and outputs.
    public let id:                      TransactionId
    
    /// Public key of the sender,
    /// Use to verify the signature
    public let sender:                  Address
    
    /// Array of all inputs
    public private(set) var inputs:     [TxInput]

    /// Array of all outputs
    /// The sum of all inputs should at least match the sum of all outputs.
    /// Any difference is considered a mining fee
    public let outputs:                 [TxOutput]
    
    /// Single signature of the transaction's hash
    /// The signature guarantees the inputs and outputs are unaltered,
    public let signature:               Signature

    /**
     Creates a new transaction. Does not validate the transaction
     The total value of the inputs match the total value of the outputs.
     In Bitcoin, the total value of the outputs can be lower. The difference is
     considered a transaction fee paid to the miner of the block.
     - parameter sender:    The sender of the transaction
     - parameter inputs:    The inputs used in this transaction
     - parameter outputs:   The outputs
     */
    public init(sender: Address, inputs: [TxInput], outputs: [TxOutput], sign: (Digest) throws -> Signature) throws {
        
        // 1.   Set inputs and outputs
        self.inputs = inputs
        self.outputs = outputs

        // 2.   Store address of sender. All outputs referenced
        //      in the inputs property of the transaction must
        //      must be owned by the sender of the transaction.
        self.sender = sender
        
        // 3.   Store the hash value of the inputs and output
        //      (Alternatively, we could not sign the inputs and
        //      outputs separately, but just a single signature
        //      in transaction of the combined hashses.)
        id = Transaction.hash(self.inputs, self.outputs)
        
        // 4.   Sign the hash of the inputs and outputs
        //      If the inputs or outputs are unaltered after signing,
        //      the verified signature is equal to the return value of
        //      the static Transaction.hash:: method.
        //      if the verified signature is not equal
        //      the inputs and outputs have been altered after signing
        //      and the transaction is not valid
        signature = try sign(id)
    }
    
    /**
     Create a transaction with only a single output, and no inputs.
     This transaction is only valid to be included in the genesis block.
     - parameter output:    Genesis block output that can be used to prefill
                            accounts for demo purposes.
    */
    public init(output: TxOutput) {
        
        // 1.   Add empty input set
        self.inputs = [TxInput]()
        
        // 2.   Add a single output
        self.outputs = [output]
        id = Transaction.hash(inputs, outputs)
        sender = Data()
        signature = Data()
    }
}

// Validation
extension Transaction {

    /**
     Creates a hash of the inputs and outputs of the inputs and outputs
     in the transaction. The hash is used for the signing the transaction.
     - parameter inputs:        Array of the inputs in the transaction.
     - parameter outputs:       Array of the outputs in the transaction.
     */
    static func hash(_ inputs: [TxInput], _ outputs: [TxOutput]) -> Data {        
        return [inputs.sha256, outputs.sha256].sha256
    }

    /**
     Validates that the signature was signed by sender and that the
     inputs and outputs are unaltered by comparing the signed hash with
     a computed hash value.
     - returns:     True if the signature is
     - throws:      Forwards error from Apple's encryption framework
     */
    func isUnaltered() throws -> Bool {
        let key = try Key(from: sender)
        return try key.verify(signature: signature, digest: Transaction.hash(inputs, outputs))
    }
    
    /**
     Checks if the transaction is a genesis transaction.
     - returns:     true if the transaction is a genesis transaction
     */
    var isGenesisTransaction: Bool {
        guard inputs.count == 0, outputs.count == 1 else { return false }
        guard sender == Data(), signature == Data() else { return false }
        return true
    }
}

// Sha256
extension Transaction: Sha256Hashable {
    var sha256: Sha256Hash {
        return try! JSONEncoder().encode(self).sha256
    }
}

extension Transaction: CustomStringConvertible {
    public var description: String {
        return "\n\ntxId: ...\(id.hexDescription.suffix(4)), sender: ...\(sender.hexDescription.suffix(4)), \ninputs: \(inputs) \noutputs: \(outputs)"
    }
}
