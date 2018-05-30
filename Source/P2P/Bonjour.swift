//
//  Bonjour.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/18/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import MultipeerConnectivity

#if canImport(UIKit)
    import UIKit
#endif

/// Look for peers. If timeout: create own blockchain
///
public protocol BonjourDelegate
{
    func didConnect(to name: String)
    func didFind(_ name: String)
    func didDisconnect(from name: String)
    func didReceive(message:String, from name: String)
    func lost(_ name: String)
    
    func error(_ error: Error)
    
    // did receive blockchain
    // did receive block
    // did receive ...
    // timeout (app should create new blockchain
}

///
final public class Bonjour: NSObject {
    
    static let serviceType = "NaiveSwiftCoin"
    
    public var delegate: BonjourDelegate? = nil
    public private(set) var peerId: MCPeerID!
    public private(set) var browser: MCNearbyServiceBrowser!
    public private(set) var advertiser: MCNearbyServiceAdvertiser!
    public private(set) var session: MCSession!
    
    public var peers = [Peer]()
    
    public init(delegate: BonjourDelegate? = nil) {
        self.delegate = delegate
        
    }
    
    public func start() {
        
        // 1.   Create PeerId based on device name
        #if canImport(UIKit)
            peerId = MCPeerID(displayName: UIDevice.current.name)
        #elseif os(macOS)
            peerId = MCPeerID(displayName: Host.current().name ?? UUID().uuidString)
        #else
            fatalError()
        #endif
        
        // 2.   Create browser
        browser = MCNearbyServiceBrowser(peer: peerId, serviceType: Bonjour.serviceType)
        browser.delegate = self
        
        // 3.   Create advertiser info
        //      Accounts can only be created if there is a blockchain,
        //      so we can't send the accounts yet
        let advertiserInfo = ["version": "1"]
        
        // 4.   Create advertiser
        advertiser  = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: advertiserInfo, serviceType: Bonjour.serviceType)
        advertiser.delegate = self
        
        // 5.   Create session
        session = MCSession(peer: peerId)
        session.delegate = self
        
        // 6.   Start searching for peers
        browser.startBrowsingForPeers()
        
        // 7.   Start advertising
        advertiser.startAdvertisingPeer()
        
        // 8. Start timer
        // TODO:
    }
}

// Sending messages
extension Bonjour {
    
    private func peer(name: String) -> MCPeerID? {
        for peer in session.connectedPeers {
            if peer.displayName == name {
                return peer
            }
        }
        return nil
    }
    
    // Sends a message to all connected peers
    public func send(_ message: Data, to name: String? = nil) throws {
        let peers: [MCPeerID]
        if let name = name, let peer = peer(name: name) {
            peers = [peer]
        } else {
            peers = session.connectedPeers
        }
        try session.send(message, toPeers: peers, with: .reliable)
    }
    
    /// Sends a string to all connected peers
    public func send(_ message: String, to name: String? = nil) throws {
        guard let data = message.data(using: .utf8) else {
            throw CoinError.serialization(message)
        }
        try send(data, to: name)
    }
    
    ///
    public func send(block: Block, to name: String? = nil) throws {
        let message = try JSONEncoder().encode(P2PBlock(params: block))
        try send(message, to: name)
    }
    
    public func send(chain: [Block], to name: String? = nil) throws {
        let message = try JSONEncoder().encode(P2PChain(params: chain))
        try send(message, to: name)
    }
    
    public func send(transaction: Transaction, to name: String? = nil) throws {
        let message = try JSONEncoder().encode(P2PQueue(params: transaction))
        try send(message, to: name)
    }
    
    
}

extension Bonjour: MCNearbyServiceBrowserDelegate {
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.lost(peerID.displayName)
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
//        delegate?. error?
    }
}

extension Bonjour: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        // 1.   Accept invitation
        invitationHandler(true, session)
        
        // HOW DO WE KNOW WE'RE CONNECTED?
        // WE SHOULD CALL DIDCONNECT AND LET MAIN CALL FETCH BLOCKCHAIN IF NECESSARY
        
        // 2.   Fetch blockchain
        
        // 3.   Create
        // Fetch blockchain
        // Create
        
        
    }
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.error(error)
    }
}
