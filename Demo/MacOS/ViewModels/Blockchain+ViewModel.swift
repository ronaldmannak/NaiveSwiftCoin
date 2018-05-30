//
//  Blockchain+ViewModel.swift
//  NaiveSwiftCoinMacOS
//
//  Created by Ronald Mannak on 5/15/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

extension Blockchain {
    
    public func txViewModel(for address: Address) -> [TxViewModel] {
        let models = longestChain.compactMap{  $0.txViewModels(for: address) }
    }
}
