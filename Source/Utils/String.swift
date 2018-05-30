//
//  String.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 5/9/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

extension String {
    
    
    /// True if string is hexadecimal
    public var isHex: Bool {
        let string = drop0xPrefix()
        // A hex must have even number of characters, or 1 (e.g. 0x1 or 0x0 is valid in Ethereum)
        guard string.count % 2 == 0 || string.count == 1 else { return false }
        guard string.isEmpty == false else { return false }
        
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        return string.uppercased().rangeOfCharacter(from: chars) == nil
    }
    
    /// Removes 0x from self if present
    public func drop0xPrefix() -> String { return has0xPrefix ? String(dropFirst(2)) : self }
    
    /// Returns true if self has 0x prefix
    public var has0xPrefix: Bool { return hasPrefix("0x") }
}
