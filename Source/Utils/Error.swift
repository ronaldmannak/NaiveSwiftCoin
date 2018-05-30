//
//  Error.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/18/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

// TODO: cleanup
enum CoinError: Error {
    
    // Block
    case invalidTransactions([Transaction])
    case miningDifficultyError(Int)
    
    
    case invalidBlock(Block)
    case emptyBlockchain
    case incorrectNonce
    
    /// Invalid transaction
    
    case insufficientFunds(UInt64, UInt64)
    
    /// TxInput references to an invalid TxOutput
    case invalidReference(TxInput)
    
    /// The provided private key label is invalid
    case invalidPrivateKeyLabel(String)
    
    /// Could not serialize string to utf8 data
    case serialization(String)
    
    case invalidPublicKey(Data)
    case invalidPublicKeyString(String)
    
    /// Crypto needs a private key to sign and decode
    /// If no private key was found (because Crypto
    /// was initialized with only a stored public key)
    /// Crypto will throw a noPrivateKey error
    case noPrivateKey
    
    case errorCreatingPublicKey
    
    case encryptionError
    
    /// Data too large to encrypt or not correct size to decrypt
    case sizeError
}
