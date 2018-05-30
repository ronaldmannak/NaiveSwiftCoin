//
//  Block+ViewModel.swift
//  NaiveSwiftCoinMacOS
//
//  Created by Ronald Mannak on 5/15/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

extension Block {
    
    func txViewModels(for address: Address) -> [TxViewModel]? {
        let viewModels = transactions.compactMap{ $0.txViewModel(for: address) }
        guard viewModels.isEmpty == false else {
            return nil
        }
        return viewModels
    }
}
