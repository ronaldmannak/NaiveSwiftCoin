//
//  Transaction+ViewModel.swift
//  NaiveSwiftCoinMacOS
//
//  Created by Ronald Mannak on 5/15/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

extension Transaction {
    
    /*
     create transaction history for address
     Find send transactions for address in [Transaction]:
     - true transaction if sender is equal to address
     - returns array of outputs, excluding the change
     - date of block
     
     send transaction: how much was being send to which address. One transaction can have multiple recipients.
     make sure to subtract the change
     
     receive transaction: find the output of any transaction that has to
 
 
     */
    
    
    /**
     returns:       
     */
    public func txViewModel(for address: Address) -> TxViewModel? {
        
        // Is this transaction a send traction by address?
        if sender == address {
            return .sendTx(SendTx.create(transaction: self))
        }
        
        // receive transaction?
        guard let received = ReceiveTx(transaction: self, recipient: address) else {
            return nil
        }
        return .receiveTx(received)
    }
    
}
