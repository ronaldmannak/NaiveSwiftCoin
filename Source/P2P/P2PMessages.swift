//
//  P2PMessages.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 5/3/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

//https://www.objc.io/blog/2018/01/23/codable-enums/
//public enum P2PCommands: Codable {
//    
//    /// Fetch blockchain from provided block index
//    case fetchChain(UInt64) //
//    
//    /// Informs other nodes to start mining
//    case mine
//    
//    /// Informs other nodes a new transaction has been created
//    /// and should be added to the queue
//    case transaction(Transaction)
//    
//    /// Created new account
//
//    case blockHeightAndHash
//}

/// 
struct P2PChain: Codable {
    let method = "chain"
    let params: [Block]
}

///
struct P2PBlock: Codable {
    let method = "block"
    let params: Block
}

/// Send a new transaction to peers
struct P2PQueue: Codable {
    let method = "transactions"
    let params: Transaction // Result
}

/// Peers should start mining the attached queue
struct P2PMine: Codable {
    let method = "mine"
    let params: [Transaction]
}
