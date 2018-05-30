//
//  Bonjour+MCSessionDelegate.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 5/3/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension Bonjour: MCSessionDelegate {
    
    public func session(_ session: MCSession, peer peerId: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            let peer = Peer(peerId: peerId, accounts: nil)
            peers.append(peer)
            // TODO: Fetch accounts
            delegate?.didConnect(to: peerId.displayName)
        case .connecting:
            delegate?.didFind(peerId.displayName)
        case .notConnected:
//            if let index = peers.filter{ $0.peerId == peerId }.first {
//                peers.remove(at: index)
//            }
            delegate?.didDisconnect(from: peerId.displayName)
        }
        
//        if (state == MCSessionStateNotConnected)
//        {
//            if (self.isWaitingForInvitation)
//            {
//                UIAlertView *alertView = [[UIAlertView alloc]
//                    initWithTitle:NSLocalizedString(@"ERROR_TITLE", nil)
//                    message:NSLocalizedString(@"ERROR_TEXT", nil)
//                    delegate:self
//                    cancelButtonTitle:NSLocalizedString(@"NO", @"Não")
//                    otherButtonTitles:NSLocalizedString(@"YES", @"Sim"),
//                    nil];
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    [alertView show];
//                    });
//                self.isWaitingForInvitation = NO;
//            }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Did receive data
        fatalError()
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        fatalError()
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Receiving \(resourceName)")
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("Received \(resourceName)")
    }
    
}
