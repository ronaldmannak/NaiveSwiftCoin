//
//  TxOut.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/20/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

/// An unsigned TxOut will be created by Account
/// Transaction will create a new TxOut with a signature
public struct TxOutput:     Codable, Equatable {
    
    /// Quick fix to make hash unique
    /// (Without it, two outputs to the same address
    /// and with the same amount would be considered one)
    public let id:          String
    
    /// Public key of the receiver of this transaction
    public let to:          Address
    
    /// Amount being sent
    public let amount:      UInt64
    
    /**
     Instantiates new txOutput. Invoked by Account
     - parameter to:        Address of recipient
     - parameter amount:    Amount of coins being sent
     */
    public init(to: Address, amount: UInt64) {
        self.to =           to
        self.amount =       amount
        self.id =           UUID().uuidString
    }
    
    /**
     Instantiates new txOutput. Invoked by Account
     - parameter to:        Address of recipient in String format
     - parameter amount:    Amount of coins being sent
     - returns:             nil if address string cannot be converted into Data
     */
    public init?(to: String, amount: UInt64) {
        guard let to =      Data(hex: to) else { return nil }
        self.to =           to
        self.amount =       amount
        self.id =           UUID().uuidString
    }
}

extension TxOutput: Sha256Hashable {
    public var sha256:      Sha256Hash {
        return try! JSONEncoder().encode(self).sha256
    }
}

extension TxOutput: CustomStringConvertible {
    public var description: String {
        return "to: ..." + to.hexDescription.suffix(4) + ", amount: \(amount)"
    }
}
