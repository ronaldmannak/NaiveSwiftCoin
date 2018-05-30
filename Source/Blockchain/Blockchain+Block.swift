//
//  Blockchain+Block.swift
//  NaiveSwiftCoinMacOS
//
//  Created by Ronald "Danger" Mannak on 5/15/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

extension Blockchain {
    
    /**
     Returns the number of conformations, which is the number of blocks
     in the blockchain after the provided block.
     - parameter block:     The refernce block
     - returns:             The number of confirmations.
     - throws:              Invalid block error if the block is not in the blockchain
     */
    public func confirmations(for block: Block) throws -> Int {
        guard let index = longestChain.index(of: block) else { throw CoinError.invalidBlock(block) }
        return longestChain.count - index - 1
    }
}
