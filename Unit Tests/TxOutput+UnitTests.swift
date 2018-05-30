//
//  TxOutput+UnitTests.swift
//  NaiveSwiftCoinMacOSTests
//
//  Created by Ronald "Danger" Mannak on 5/14/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
@testable import NaiveSwiftCoinMacOS

extension TxOutput {
    /**
     Custom initializer for unit tests that sets id to predetermined string.
     */
    public init(to: Address, amount: UInt64, id: String) {
        self.to =           to
        self.amount =       amount
        self.id =           id
    }
    
}
