//
//  UInt64.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/19/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

// Source: https://stackoverflow.com/questions/26549830/swift-random-number-for-64-bit-integers

extension UInt64 {
    
    /// Random function for UInt64
    static var random: UInt64 {
        let hex = UUID().uuidString
            .components(separatedBy: "-")
            .suffix(2)
            .joined()
        return UInt64(hex, radix: 0x10)!
    }
}
