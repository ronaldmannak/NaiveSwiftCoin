//
//  Data.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/28/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

extension Data {
    
    /// Hexadecimal string representations of the object
    var hexDescription: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
    
    /// Binary string representation of the object
    var binaryDescription: String {
        return reduce("") { $0 + String($1, radix: 2) }
    }
    
    /**
     Initializes Data based on a hexadecimal string.
     Note: UInt16 has a bigEndian property if needed, e.g.:
     
         self = NSData(bytes: [UInt16(0x007F).bigEndian], length: 2) as Data
     - parameter hex:       Hexadecimal string representation, e.g. "12EA34"
     - returns:             Nil if hex string isn't a valid hexadecimal representation
     */
    init?(hex: String) {
        
        guard hex.isHex == true else { return nil }
    
        var hex = hex
        var data = Data()
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        self = data
    }
}
