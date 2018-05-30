//
//  Typealias.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/20/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

/// Address is the public key and is stored as Data
/// to use the public key for verifications or encryption,
/// restore the key to its original SecKeyRef format using
/// the import method in Crypto
/// To export a SecKey public key to Data, use the
/// export method in Crypto
public typealias Address = Data

/// The private key
//public typealias PrivateKey = String

/// Reference to the transaction ID
public typealias TransactionId = Data

/// Amount of coins
public typealias Amount = UInt64

public typealias Sha256Hash = Data

/// The index of a block. The genesis block
/// always has index 0
public typealias BlockIndex = Int

public typealias Signature = Data

/// Digest hashed using Sha256
public typealias Digest = Data
