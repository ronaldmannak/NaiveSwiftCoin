//
//  Blockchain+Collection.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/22/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

// Convience accessors to blocks
extension Blockchain: BidirectionalCollection {
    
    public typealias Element = Block
    public typealias Index = Int
    public typealias Iterator = IndexingIterator<Array<Element>>
    
    /// Returns the genesis block
    public var first: Block? { return longestChain.first }
    
    /// Returns the latest block
    public var last: Block? { return longestChain.last }
    
    /// Returns the index of the genesis block
    public var startIndex: Int { return longestChain.first!.index }
    
    /// Returns the index of the latest block
    public var endIndex: Int { return longestChain.last!.index }
    
    public func index(before i: Int) -> Int { return longestChain.index(before: i) }
    
    public func index(after i: Int) -> Int { return longestChain.index(after: i) }
    
    public subscript(position: Int) -> Block {
        return longestChain.filter{($0.index == position)}.first!
    }
    
    public var isEmpty: Bool { return longestChain.isEmpty }
    
    public func makeIterator() -> Blockchain.Iterator {
        return longestChain.makeIterator()
    }
    
    public var count: Int { return longestChain.count }
}

extension Blockchain: CustomStringConvertible {
    public var description: String {
        return longestChain.enumerated().map { "\($0): \($1)" }.reduce(""){ "\($0)\n\($1)\n" }
    }
}
