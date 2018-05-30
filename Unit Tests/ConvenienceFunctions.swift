//
//  ConvenienceFunctions.swift
//  NaiveCoinTests
//
//  Created by Ronald Mannak on 5/11/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
@testable import NaiveSwiftCoinMacOS

func createValidInputs() -> [TxInput] {
    return [TxInput(blockIndex: 0, txIndex: 0, txOutputHash: Data()), TxInput(blockIndex: 1, txIndex: 1, txOutputHash: "5678".sha256)]
}

func createValidOutputs(from sender: Key) throws -> [TxOutput] {
    return [TxOutput(to: Data(), amount: 200), TxOutput(to: try sender.exportKey(), amount: 10)]
}

func createInvalidOutputs() -> [TxOutput] {
    return [TxOutput(to: Data(), amount: 200, id: "1234"), TxOutput(to: Data(), amount: 10, id: "1234")]
}


func createValidTransaction(from sender: Key) throws -> Transaction {
    return try Transaction(
        sender: sender.exportKey(),
        inputs: createValidInputs(),
        outputs: createValidOutputs(from: sender)) { try sender.sign($0)}
}

func createAlteredTransaction(from sender: Key) throws -> Transaction {
    return try Transaction(
        sender: sender.exportKey(),
        inputs: createValidInputs(),
        outputs: createInvalidOutputs()) { _ in try createValidTransaction(from: sender).signature }
}

func createValidBlock(from sender: Key, previous: Block) throws -> Block {
    return try Block.mine(transactions: [createValidTransaction(from: sender)], previous: previous, difficulty: 1)
}

func createAlteredBlock(from sender: Key, previous: Block) throws -> Block {
    return try Block.mine(transactions: [createAlteredTransaction(from: sender)], previous: previous, difficulty: 1)
}

