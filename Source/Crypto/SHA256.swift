//
//  SHA256.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/19/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

/// Protocol for SHA256 Hash
/// Source: https://stackoverflow.com/questions/25388747/sha256-in-swift
protocol Sha256Hashable {
    
    /// The sha256 value in Data format
    var sha256: Sha256Hash { get }
    
    /// The sha256 value in String format
    var sha256StringValue: String { get }
}

extension Sha256Hashable {
    var sha256StringValue: String {
        return String(describing: String(bytes: sha256, encoding: .utf8))
    }
}

extension Data: Sha256Hashable {
    var sha256: Sha256Hash {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(self.count), &hash)
        }
        return Data(bytes: hash)
    }
}

extension String: Sha256Hashable {
    var sha256: Sha256Hash { return self.data(using: .utf8)!.sha256 }
}

extension Int: Sha256Hashable {
    var sha256: Sha256Hash { return String(self, radix: 16, uppercase: false).data(using: .utf8)!.sha256 }
}

extension UInt32: Sha256Hashable {
    var sha256: Sha256Hash { return String(self, radix: 16, uppercase: false).data(using: .utf8)!.sha256 }
}

extension Array where Element: Sha256Hashable & Codable {
    var sha256: Sha256Hash {
        return try! JSONEncoder().encode(self).sha256
    }
}
