//
//  Blockchain+Transactions.swift
//  NaiveSwiftCoinMacOS
//
//  Created by Ronald Mannak on 5/15/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

extension Blockchain {
    
    /**
     Fetches the transaction history of address.
     - parameter for:       Address in string format
     - returns:             All transactions in the blockchain belong to address
     */
    public func transactions(for address: String) -> [Transaction] {

        // Fetch all transaction that sent coins from address
        let txs = longestChain.flatMap{ $0.transactions }.filter{
            ($0.sender.hexDescription == address) ||
            $0.outputs.filter{ $0.to.hexDescription == address }.isEmpty == false
        }
        
        return txs
    }
    
//    public func queuedTransactions(for address: String) -> [Transaction] {
//        
//    }
}
