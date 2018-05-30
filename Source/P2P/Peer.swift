//
//  Peer.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 5/4/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public struct Peer {
    public unowned let peerId: MCPeerID
    public let accounts: [String: Address]?
    public var displayName: String { return peerId.displayName }
}
