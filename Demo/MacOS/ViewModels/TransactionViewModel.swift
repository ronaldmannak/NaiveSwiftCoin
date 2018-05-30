//
//  TransactionViewModel.swift
//  NaiveSwiftCoinMacOS
//
//  Created by Ronald Mannak on 5/15/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

/**
 Transaction view model
 */
public enum TxViewModel {
    case sendTx([SendTx])
    case receiveTx(ReceiveTx)
    
    func add(block: Block) throws -> TxViewModel {
        switch self {
        case .receiveTx(let tx):
            return try .receiveTx(ReceiveTx(tx: tx, block: block))
        case .sendTx(let txs):
            return try .sendTx(txs.map{ try SendTx(tx: $0, block: block) })
        }
    }
    
    func add(chain: Blockchain) throws -> TxViewModel {
        
    }
}

/**
 View model
 */
public struct SendTx {
    let id:             TransactionId
    let to:             Address
    let amount:         Amount
    let timestamp:      TimeInterval?
    let blockIndex:     BlockIndex?
    let confirmations:  Int?
    
    init(id: TransactionId, to: Address, amount: Amount) {
        self.id =       id
        self.to =       to
        self.amount =   amount
        timestamp =     nil
        blockIndex =    nil
        confirmations = nil
    }
    
    init(tx: SendTx, block: Block) throws {
        self.id =       tx.id
        self.to =       tx.to
        self.amount =   tx.amount
        timestamp =     block.timestamp
        blockIndex =    block.index
        confirmations =  nil
    }
    
    /**
     
     */
    static func create(transaction: Transaction) -> [SendTx] {
        return transaction.outputs.filter { $0.to != transaction.sender }.map { SendTx(id: transaction.id, to: $0.to, amount: $0.amount) }
    }
}

/**
 View model
 */
public struct ReceiveTx {
    let id:             TransactionId
    let from:           Address
    let amount:         Amount
    let timestamp:      TimeInterval?   // nil if transaction is in the transaction queue
    let blockIndex:     Int?
    let confirmations:  Int?            // nil if transaction is in the transaction queue
    
    /**
     Initializes a new ReceiveTX with all outputs
     Invoked by transaction
     - returns:         returns nil if transaction does not contain any outputs to recipient
     */
    init?(tx: Transaction, recipient: Address) {
        id =            tx.id
        from =          tx.sender
        amount =        tx.outputs.filter{ $0.to == recipient }.reduce(0){ $0 + $1.amount }
        timestamp =     nil
        blockIndex =    nil
        confirmations = nil
        guard amount > 0 else { return nil } // This transaction does not contain any transaction to recipient
    }
    
    /**
     
     */
    init(tx: ReceiveTx, block: Block) throws {
        id =            tx.id
        from =          tx.from
        amount =        tx.amount
        timestamp =     block.timestamp
        blockIndex =    block.index
        confirmations = nil
//        confirmations = try chain.confirmations(for: block)
    }
}
