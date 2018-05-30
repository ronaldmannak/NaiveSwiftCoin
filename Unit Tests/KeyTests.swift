//
//  KeyTests.swift
//  NaiveCoinTests
//
//  Created by Ronald Mannak on 5/3/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import XCTest
@testable import NaiveSwiftCoinMacOS

class KeyTests: XCTestCase {
    
    var key: Key!
    
    override func setUp() {
        
        super.setUp()
        
        // Create a new keypair
        do {
            key = try Key(with: UUID(), prompt: "Sign transaction")
        } catch {
            XCTFail("caught: \(error)")
        }
    }
    
    override func tearDown() {
        
        key = nil
        super.tearDown()
    }
    
    func testCreateKeyPair() {
        do {
            
            // Verify the public key exports, isn't empty and starts with "04"
            // (all elliptic curve public keys have a 04 prefix)
            let publicKey1 = try key.exportKey()
            XCTAssert(publicKey1.isEmpty == false)
            XCTAssert(publicKey1.hexDescription.prefix(2) == "04")
            print(publicKey1.hexDescription.count)
            print(publicKey1.hexDescription)
            
            // Verify that an exported public key can be imported again
            let restoredKey = try Key(from: publicKey1).exportKey()
            XCTAssert(publicKey1 == restoredKey)
            
            // Verify that an different imported public key is not the same
            let wrongKey = try Key(with: UUID()).exportKey()
            XCTAssert(publicKey1 != wrongKey)
            
            // Verify only elliptic curve keys can be imported
            let invalidKey = "NotAKey".data(using: .utf8)!
            XCTAssertThrowsError(try Key(from: invalidKey))
            
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSignature() {
        do {
            
            let data1 = "1234".data(using: .utf8)!.sha256
            let data2 = "æøå".data(using: .utf8)!.sha256
            let secondKey = try Key(with: UUID())
            
            print(String(bytes: data1, encoding: .utf8)!)
            print(String(bytes: data2, encoding: .utf8)!)
            
            // Verify sign returns non empty values
            XCTAssertFalse(try key.sign(data1).isEmpty)
            XCTAssertFalse(try key.sign(data2).isEmpty)
            
            // Sign and verify data1 with correct key
            XCTAssertTrue(try key.verify(signature: key.sign(data1), digest: data1))
            XCTAssertTrue(try key.verify(signature: key.sign(data2), digest: data2))
            XCTAssertTrue(try secondKey.verify(signature: secondKey.sign(data2), digest: data2))
            
            // Sign and verify data1 with two different keys
            XCTAssertThrowsError(try secondKey.verify(signature: key.sign(data1), digest: data1))
            XCTAssertThrowsError(try key.verify(signature: secondKey.sign(data1), digest: data1))
            
            // Sign data1 and verify with data2
            XCTAssertThrowsError(try key.verify(signature: key.sign(data1), digest: data2))
            
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
    }
    
    func testEncryption() {
        
        do {
            let data1 = "1234".data(using: .utf8)!
            let data2 = "abcd".data(using: .utf8)!
            let secondKey = try Key(with: UUID())
            
            // Verify encrypted data is not empty
            XCTAssert(try key.encrypt(data1).isEmpty == false)
            XCTAssert(try key.encrypt(data2).isEmpty == false)

            // Verify decrypting encrypted returns the correct data
            XCTAssertEqual(try key.decrypt(key.encrypt(data1)), data1)
            XCTAssertEqual(try key.decrypt(key.encrypt(data2)), data2)
            
            // Sanity check
            XCTAssertNotEqual(try key.decrypt(key.encrypt(data2)), data1)
            XCTAssertNotEqual(try key.decrypt(key.encrypt(data1)), data2)
            
            // Verify decrypt throws when decrypting with the wrong key
            XCTAssertThrowsError(try key.decrypt(secondKey.encrypt(data2)))
            XCTAssertThrowsError(try secondKey.decrypt(key.encrypt(data2)))
            
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSignatureRoundtrip() {
        do {
            let digest = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed pretium semper libero, id pulvinar nisl convallis sed. Integer placerat venenatis finibus.".data(using: .utf8)!.sha256
            let wrongDigest = "1234".data(using: .utf8)!.sha256
            
            // sender signs
            let signature = try key.sign(digest)
            
            // receiver verifies if signature is valid
            let receiver = try Key(from: key.exportKey())
            XCTAssert(try receiver.verify(signature: signature, digest: digest) == true)
            
            // Sanity checks
            XCTAssert(signature.isEmpty == false)
            XCTAssertThrowsError(try receiver.verify(signature: signature, digest: wrongDigest))
            
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testEncryptionRoundtrip() {
        do {
            let data = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed pretium semper libero, id pulvinar nisl convallis sed. Integer placerat venenatis finibus.".data(using: .utf8)!
            let wrongData = "1234".data(using: .utf8)!
            
            // sender encrypts with public key
            let sender = try Key(from: key.exportKey())
            let cipherText = try sender.encrypt(data)
            
            // receiver decrypts with private key
            XCTAssert(try key.decrypt(cipherText) == data)
            
            // Sanity checks
            XCTAssert(cipherText.isEmpty == false)
            XCTAssert(try key.decrypt(cipherText) != wrongData)
            
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSerialization() {
        do {
            let exportedKeyString = try key.exportKey().hexDescription
            print("exported key: \(exportedKeyString)")
            guard let data = Data(hex: exportedKeyString) else {
                print("invalid")
                return
            }
            print("reimported key: \(data.hexDescription)")
            
            XCTAssertEqual(try key.exportKey(), Data(hex: try key.exportKey().hexDescription))
            
            let importedKey = try Key(from: exportedKeyString)
                        
            XCTAssertEqual(try key.exportKey(), try importedKey.exportKey())
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
