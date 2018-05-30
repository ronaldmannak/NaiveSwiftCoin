//
//  TxIn.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/20/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

/**
 TxInput is a reference to a TxOutput. A TxOutput that is referenced by a TxInput
 is a spent output. TxOutputs that are not referenced by a TxOutput, are unspent outputs (utxos).
 
 To be valid, a TxInput must conform to the following rules:
 1) A TxInput can only refer to one single TxOutput
 2) Not more than one TxOutput can refer a TxOutput.
 3) The to address in the referenced TxOutput must be equal to the sender
    address in the transaction. You can only spend money that you own.
 
 */
public struct TxInput:          Codable, Equatable {
    
    /// References the block index number of the referenced TxOutput
    public let blockIndex:      BlockIndex

    // The index of the transaction in the block
    public let txIndex:         Int
    
    /// The hash value of the output
    /// Used to find spent outputs in Blockchain
    public let txOutputHash:     Sha256Hash
    
    /**
     Creates an input. An input is a reference to an unspent output owned by the creator of the input
     Invoked by Account
     - parameter blockIndex:    The index of the block the output referenced is stored in
     - parameter txIndex:       Transaction index of the transaction in the transaction array
                                in the block that contains the referenced output
     - parameter txOutputHash:  The sha256 hash of the output referenced
     */
    public init(blockIndex: BlockIndex, txIndex: Int, txOutputHash: Sha256Hash) {
        self.blockIndex =       blockIndex
        self.txIndex =          txIndex
        self.txOutputHash =     txOutputHash
    }
}

extension TxInput: Sha256Hashable {
    
    /// Computed Sha256 Hash of TxInput.
    var sha256:                 Sha256Hash {
        return try! JSONEncoder().encode(self).sha256
    }
}

extension TxInput: CustomStringConvertible {
    public var description:     String {
        return "Block: \(blockIndex), txIndex: \(txIndex), outputSig: ...\(txOutputHash.hexDescription.suffix(4))"
    }
}
