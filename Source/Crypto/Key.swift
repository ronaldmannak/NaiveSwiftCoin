//
//  Key.swift
//  NaiveSwiftCoin
//
//  Created by Ronald Mannak on 5/6/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import LocalAuthentication


/**
 
 Key uses the secure enclave on the iOS device or Mac computer if present.
 If not, Key falls back to the Keychain gracefully.
 
 The following devices will automatically create and store the private key
 in the secure enclave:
 - iOS devices with an A7 processor or later
 - MacBook Pros with a TouchBar
 - iMac Pro
 
 All other devices will automaticall fall back on the iOS, tvOS, or
 MacOS Keychain.
 
 See also:
 
 - [A Tale of Two Curves](http://blog.enuma.io/update/2016/11/01/a-tale-of-two-curves-hardware-signing-for-ethereum.html)
 - [EllipticCurveKeyPair](https://github.com/agens-no/EllipticCurveKeyPair)
 */
struct Key {

    /// Stores the public key
    fileprivate let publicKey: SecKey
    
    /// Stores reference to the private key
    /// A privateKey will be nil when Key is initiated with an
    /// imported key.
    fileprivate let privateKey: SecKey?
    
    /// The algorithms used.
    /// The sign algorithm creates a sha256 hash of the data first before signing.
    fileprivate static let signAlgorithm = SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256
    fileprivate static let encryptionAlgorithm = SecKeyAlgorithm.eciesEncryptionStandardX963SHA256AESGCM
    fileprivate static let keyType = kSecAttrKeyTypeECSECPrimeRandom
    fileprivate static let applicationTag = "org.naiveswiftcoin."
    
    /// True if the app has access to the Secure Enclave
    public static var hasSecureEnclave: Bool {
        var isSimulator: Bool {
            #if targetEnvironment(simulator)
            return true
            #else
            return false
            #endif
        }
        var hasBiometrics: Bool {
            return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        }
        
        // Secure enclave is available if the device has
        // biometrics and the app isn't running in the simulator
        return hasBiometrics && !isSimulator
    }

    /**
     Initializes Key with the UUID as label.
     See also:
     - Apple documentation [Storing Keys in the Secure Enclave](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_secure_enclave)
     - https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/generating_new_cryptographic_keys
     - parameter uuid:              A unique UUID used to store and access the keypair in the
                                    keychain or secure enclave
     - parameter useSecureEnclave:  If false, the secure enclave won't be used. If set to true and
                                    the device doesn't have a secure enclave, Key will gracefully
                                    fall back to the Keychain
     - parameter prompt:            Prompt the user is presented to explain the reason
                                    for TouchID or FaceID
     - throws:                      errorCreatingPublicKey or error thrown by the security and
                                    authentication framework
     */
    init(with uuid: UUID, useSecureEnclave: Bool = true, prompt: String? = nil) throws {
        
        var error: Unmanaged<CFError>?
        
        // 1.   Normally you would search the Keychain for an existing
        //      keypair first. But since this demo doesn't persist keys (nor data)
        //      We're skipping this step. See for more info:
        //      https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_keychain
        
        // 2.   Use secure enclave if device has one and is requested
        let useSecureEnclave = useSecureEnclave && Key.hasSecureEnclave
        
        // 3.   Private key access control
        //      .privateKeyUsage makes the key accessible for signing and verification
        //      See https://developer.apple.com/documentation/security/secaccesscontrolcreateflags
        let privateAccessControl: SecAccessControlCreateFlags = useSecureEnclave ?  [.userPresence, .privateKeyUsage] : [.userPresence]
        guard let privateKeyAccess = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, privateAccessControl, &error) else {
            throw error!.takeRetainedValue() as Error
        }

        // 5.   Private key attributes
        var privateKeyAttributes: [String: Any] = [
            kSecClass as String:                    kSecClassKey,
            kSecAttrKeyClass as String:             kSecAttrKeyClassPrivate,
//            kSecReturnRef as String: true,
            kSecAttrLabel as String:                (Key.applicationTag + "private").data(using: .utf8)!,
            kSecAttrIsPermanent as String:          true, // TODO: false
            kSecAttrAccessControl as String:        privateKeyAccess,
            kSecUseAuthenticationUI as String:      kSecUseAuthenticationUIAllow,
            kSecUseAuthenticationContext as String: LAContext(),
            kSecUseOperationPrompt as String:       "Hello".data(using: .utf8)!,
            kSecAttrCanEncrypt as String:           false,
        ]
//        if let prompt = prompt {
//            privateKeyAttributes[kSecUseOperationPrompt as String] = prompt
//        }
        
        // 6.   Public key attributes
        let publicKeyAttributes: [String: Any] = [
            kSecAttrLabel as String:                (Key.applicationTag + "public").data(using: .utf8)!,
            kSecAttrAccessControl as String:        [kSecAttrAccessibleAlwaysThisDeviceOnly],
        ]
        
        // 7.   Assemble the attributes
        var attributes: [String: Any] = [
            kSecAttrKeyType as String:              Key.keyType,
            kSecAttrKeySizeInBits as String:        256,            // 256-bit elliptic curve keys
            kSecPrivateKeyAttrs as String:          privateKeyAttributes,
            kSecPublicKeyAttrs as String:           publicKeyAttributes,
        ]
        
        // 8.   Use secure enclave if possible
        if useSecureEnclave == true {
            attributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
        }
        
        // 9.   Create a new random private key
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error // throws
        }
        
        // 10.  Obtain the public key
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw CoinError.errorCreatingPublicKey
        }
        
        // 11.  Set the private and public key properties
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
    
    /**
     Initialize Key with a public key stored as a Data object, in the format produced
     by the exportKey method. The private key will be set to nil. Usually the public
     key provided is someone else's public key. Their public key is used to validate
     their signature.
     See: Apple documentation [Storing Keys as Data](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_as_data)
     - parameter data:              The saved public key in Data format
     - throws:                      Error thrown by SecKeyCreateWithData:::
    */
    init(from address: Address) throws {
        
        // 1.   Recreate SecKey from data
        var error: Unmanaged<CFError>?
        let options: [String: Any] = [
            kSecAttrKeyType as String:              Key.keyType,
            kSecAttrKeyClass as String:             kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String:        256,
        ]
        guard let publicKey = SecKeyCreateWithData(address as CFData, options as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        // 2.   Validate key (might be redudant, since we've already passed the options in the previous step
        guard SecKeyIsAlgorithmSupported(publicKey, .verify, .ecdsaSignatureMessageX962SHA256) else {
            throw CoinError.invalidPublicKey(address)
        }
        
        // 3. Set publicKey, and leave private key nil
        self.publicKey = publicKey
        self.privateKey = nil
    }
    
    init(from string: String) throws {
        guard let data = Data(hex: string) else {
            throw CoinError.invalidPublicKeyString(string)
        }
        try self.init(from: data)
    }
    
    /**
     Exports the public key to a transmittable and saveable data format.
     Use init:from address to import an exported key
     See: Apple documentation [Storing Keys as Data](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_as_data)
     - returns:                 Public key as Address (a typealias of Data)
     */
    func exportKey() throws -> Address {
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(publicKey, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        return data as Data
    }
}


// Signing and Verifying
extension Key {
    
    /**
     Signs the digest (the SHA256 hash) of digest with the private key stored in the privateKey property.
     Usually, we'll pass a digest instead of the original data, and the digest will be hashed
     twice before being signed.
     See also:
     - Apple Documentation [Signing and Verifying](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/signing_and_verifying)
     - requires:                Private key to be non nil
     - parameter digest:        Digest to be signed
     - returns:                 The signature of data
     */
    public func sign(_ digest: Data) throws -> Signature {
        
        // 1.   Signing requires a private key
        //      Make sure there is one.
        guard let privateKey = privateKey else {
            throw CoinError.noPrivateKey
        }
        
        // 2.   Sign the data
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey, Key.signAlgorithm, digest as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        // 3.   Return signature
        return signature
    }
    
    /**
     Verifies if signature was signed by the private key corrosponding to
     the public key property stored in the Key instance.
     See also:
     - Apple Documentation [Signing and Verifying](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/signing_and_verifying)
     - parameter signature:     The signature of the digest
     - parameter digest:        The SHA256 digest of the data to be verified
     - returns:                 Returns true if the signature was signed by the private key
                                belonging to the publicKey stored in the Key instance. This
                                method does not return false. Instead, it throws an error.
     - throws:                  Error received from SecKeyVerifySignature function.
                                If the signature cannot be validated, verify throws an
                                "EC signature verification failed, no match" Error (code -67808)
     */
    public func verify(signature: Signature, digest: Data) throws -> Bool {
        // 1.   Verify signature
        var error: Unmanaged<CFError>?
        let verified = SecKeyVerifySignature(publicKey, Key.signAlgorithm, digest as CFData, signature as CFData, &error)
        
        // 2.   If an error was returned, throw
        guard error == nil else {
            throw error!.takeRetainedValue() as Error
        }
        
        // 3.   Return true or false
        return verified
    }
}

// Encryption
extension Key {
    
    /**
     Encrypts data using the publicKey property.
     See also:
     - Apple documentation [Using Keys for Encryption](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/using_keys_for_encryption)
     - returns:                 The encrypted cipherText
     - throws:                  EncryptionError when the public key doesn't support the algorithm,
                                or a crypto error when the data cannot be encrypted.
     */
    public func encrypt(_ data: Data) throws -> Data {
        
        // 1.   Verify public key can be used to encrypt
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, Key.encryptionAlgorithm) else {
            throw CoinError.encryptionError
        }
        
        // 2.   Encrypt
        var error: Unmanaged<CFError>?
        guard let cipherText = SecKeyCreateEncryptedData(publicKey, Key.encryptionAlgorithm, data as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }

        // 3.   Return encrypted data
        return cipherText
    }
    
    /**
     Decrypts the cipherText with the privateKey property
     See also:
     - Apple documentation [Using Keys for Encryption](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/using_keys_for_encryption)     
     - throws:                  EncryptionError when the private key doesn't support the algorithm,
                                or a crypto error when the data cannot be decrypted.
     - returns:                 Decrypted clearText in Data format
     */
    public func decrypt(_ cipherText: Data) throws -> Data {

        // 1.   Verify private key can be used to decrypt
        guard let privateKey = privateKey, SecKeyIsAlgorithmSupported(privateKey, .decrypt, Key.encryptionAlgorithm) else {
            throw CoinError.encryptionError
        }
        
        // 2.   Decrypt data
        var error: Unmanaged<CFError>?
        guard let clearText = SecKeyCreateDecryptedData(privateKey, Key.encryptionAlgorithm, cipherText as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        // 3.   Return clear text
        return clearText
    }
}


