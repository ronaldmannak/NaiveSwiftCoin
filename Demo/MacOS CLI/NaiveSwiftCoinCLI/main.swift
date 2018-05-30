//
//  main.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 4/18/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

// Protocols: https://en.bitcoin.it/wiki/Protocol_documentation#Signatures


// TODO: why aren't arrays of codables automatically codable, but sets are? https://swift.org/blog/conditional-conformance/

import Foundation
import LocalAuthentication
/*
struct Shared {
    
    static let keypair: EllipticCurveKeyPair.Manager = {
        EllipticCurveKeyPair.logger = { print($0) }
        let publicAccessControl = EllipticCurveKeyPair.AccessControl(protection: kSecAttrAccessibleAlwaysThisDeviceOnly, flags: [])
        let privateAccessControl = EllipticCurveKeyPair.AccessControl(protection: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, flags: {
            return EllipticCurveKeyPair.Device.hasSecureEnclave ? [.userPresence, .privateKeyUsage] : [.userPresence]
        }())
        let config = EllipticCurveKeyPair.Config(
            publicLabel: "no.agens.sign.public",
            privateLabel: "no.agens.sign.private",
            operationPrompt: "Sign transaction",
            publicKeyAccessControl: publicAccessControl,
            privateKeyAccessControl: privateAccessControl,
            token: .secureEnclaveIfAvailable)
        return EllipticCurveKeyPair.Manager(config: config)
    }()
}

var context: LAContext! = LAContext()

do {
    let key = try Shared.keypair.publicKey().data()
    print("Public key: \(key.PEM)")
} catch {
    print("Error: \(error)")
}


let digest = "Lorem ipsum dolor sit amet"

    /*
     Using the DispatchQueue.roundTrip defined in Utils.swift is totally optional.
     What's important is that you call `sign` on a different thread than main.
     */
    
    DispatchQueue.roundTrip({
        guard let digest = "foo".data(using: .utf8) else {
            throw "Missing text in unencrypted text field"
        }
        return digest
    }, thenAsync: { digest in
        return try Shared.keypair.sign(digest, hash: .sha256, context: context)
    }, thenOnMain: { digest, signature in
        try Shared.keypair.verify(signature: signature, originalDigest: digest, hash: .sha256)
        try printVerifySignatureInOpenssl(manager: Shared.keypair, signed: signature, digest: digest, hashAlgorithm: "sha256")
        print(signature.base64EncodedString())
    }, catchToMain: { error in
        print("Error: \(error)")
    }) */




do {
    // Set up blockchain, wallet and two accounts
    var blockchain = try Blockchain()
    var wallet = Wallet(with: blockchain)
    let account1 = try wallet.createAccount()
//    let account2 = try wallet.createAccount()

//    try account1.addInitialAmount(blockchain: blockchain)
//    print(wallet) // both accounts should own 500 coins
//    try account1.send(amount: 200, to: account2.address, blockchain: blockchain)
//    print(wallet)
} catch {
    print("======\n\(error)")
    fatalError()
}


// 1. Send money from account 1 to 2
// User inputs as string, will be data
// 2. Connect crypto
// 3. Verify transactions



//var mined = false
//while mined == false {
//    if let block = blockchain.append(data: "Hello, World!") {
//        mined = true
//        print("Success: \(block)")
//    }
//}


/*try! blockchain.append(data: "And another block")
try! blockchain.append(data: "Fourth block (including genesis block)")
print(blockchain)

print("\nis a valid blockchain: \(blockchain.isValid)")

print(blockchain[0])
print(blockchain[2])
print(blockchain.last!)
*/


// Initialization
// Step 1: Start node
// Step 2: See if there is a node on the network active
// Step 3: If not, create a new blockchain, if there is then download blockchain
// Step 4: Create a new Wallet with the blockchain from step 3 with an new key pair
// Step 5:

//
