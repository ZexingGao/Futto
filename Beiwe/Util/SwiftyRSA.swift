//
//  SwiftyRSA.swift
//  SwiftyRSA
//
//  Created by Loïs Di Qual on 7/2/15.
//  Copyright (c) 2015 Scoop Technologies, Inc. All rights reserved.
//
// Modification by KG

/*
 The MIT License (MIT)

 Copyright (c) 2015 Scoop Technologies, Inc.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import Foundation
import Security

open class SwiftyRSAError: NSError {
    init(message: String) {
        super.init(domain: "com.takescoop.SwiftyRSA", code: 500, userInfo: [
            NSLocalizedDescriptionKey: message
            ])
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc
open class SwiftyRSA: NSObject {

    fileprivate var keyTags: [Data] = []
    public static let defaultPadding: SecPadding = .PKCS1

    // MARK: - Public Shorthands

    open class func encryptString(_ str: String, publicKeyPEM: String, padding: SecPadding = defaultPadding) throws -> String {
        let rsa = SwiftyRSA()
        let key = try rsa.publicKeyFromPEMString(publicKeyPEM)
        return try rsa.encryptString(str, publicKey: key, padding: padding)
    }

    open class func encryptString(_ str: String, publicKeyId: String, padding: SecPadding = defaultPadding) throws -> String {
        let rsa = SwiftyRSA()
        let key = try rsa.publicKeyFromId(publicKeyId)
        return try rsa.encryptString(str, publicKey: key, padding: padding)
    }

    open class func encryptString(_ str: String, publicKeyDER: Data, padding: SecPadding = defaultPadding) throws -> String {
        let rsa = SwiftyRSA()
        let key = try rsa.publicKeyFromDERData(publicKeyDER)
        return try rsa.encryptString(str, publicKey: key, padding: padding)
    }

    open class func encryptString(_ str: String, publicKey: SecKey, padding: SecPadding = defaultPadding) throws -> String {
        let rsa = SwiftyRSA()
        return try rsa.encryptString(str, publicKey: publicKey, padding: padding)
    }

    open class func decryptString(_ str: String, privateKeyPEM: String, padding: SecPadding = defaultPadding) throws -> String {
        let rsa = SwiftyRSA()
        let key = try rsa.privateKeyFromPEMString(privateKeyPEM)
        return try rsa.decryptString(str, privateKey: key, padding: padding)
    }

    open class func storePublicKey(_ publicKeyPEM: String, keyId: String) throws -> SecKey  {
        let rsa = SwiftyRSA()
        let data = try rsa.dataFromPEMKey(publicKeyPEM)
        let keyref = try rsa.addKey(data, isPublic: true, keyId: keyId)
        return keyref
    }


    // MARK: - Public Advanced Methods

    public override init() {
        super.init()
    }

    open func publicKeyFromId(_ keyId: String) throws -> SecKey {
        return try fetchKey(keyId, isPublic: true)
    }


    open func publicKeyFromDERData(_ keyData: Data) throws -> SecKey {
        return try addKey(keyData, isPublic: true)
    }

    open func publicKeyFromPEMString(_ key: String) throws -> SecKey {
        let data = try dataFromPEMKey(key)
        return try addKey(data, isPublic: true)
    }

    open func privateKeyFromPEMString(_ key: String) throws -> SecKey {
        let data = try dataFromPEMKey(key)
        return try addKey(data, isPublic: false)
    }

    open func encryptString(_ str: String, publicKey: SecKey, padding: SecPadding = defaultPadding) throws -> String {
        let blockSize = SecKeyGetBlockSize(publicKey)
        let plainTextData = [UInt8](str.utf8)
        let plainTextDataLength = Int(str.characters.count)
        var encryptedData = [UInt8](repeating: 0, count: Int(blockSize))
        var encryptedDataLength = blockSize

        let status = SecKeyEncrypt(publicKey, padding, plainTextData, plainTextDataLength, &encryptedData, &encryptedDataLength)
        if status != noErr {
            throw SwiftyRSAError(message: "encryptStringErr. OSStatus: \(status)")
        }

        let data = Data(bytes: UnsafePointer<UInt8>(encryptedData), count: encryptedDataLength)
        return data.base64EncodedString(options: [])
    }

    open func decryptString(_ str: String, privateKey: SecKey, padding: SecPadding = defaultPadding) throws -> String {

        guard let data = Data(base64Encoded: str, options: []) else {
            throw SwiftyRSAError(message: "Couldn't decode base 64 encoded string")
        }

        let blockSize = SecKeyGetBlockSize(privateKey)

        var encryptedData = [UInt8](repeating: 0, count: blockSize)
        (data as NSData).getBytes(&encryptedData, length: blockSize)

        var decryptedData = [UInt8](repeating: 0, count: Int(blockSize))
        var decryptedDataLength = blockSize

        let status = SecKeyDecrypt(privateKey, padding, encryptedData, blockSize, &decryptedData, &decryptedDataLength)
        if status != noErr {
            throw SwiftyRSAError(message: "Couldn't decrypt provided string. OSStatus: \(status)")
        }

        let decryptedNSData = Data(bytes: UnsafePointer<UInt8>(decryptedData), count: decryptedDataLength)
        guard let decryptedString = NSString(data: decryptedNSData, encoding: String.Encoding.utf8.rawValue) else {
            throw SwiftyRSAError(message: "Couldn't convert decrypted data to UTF8 string")
        }

        return decryptedString as String
    }

    // MARK: - Private

    fileprivate func addKey(_ keyData: Data, isPublic: Bool, keyId: String? = nil) throws -> SecKey {

        var keyData = keyData

        // Strip key header if necessary
        if isPublic {
            try keyData = stripPublicKeyHeader(keyData)
        }

        let tag = keyId ?? UUID().uuidString
        let tagData = Data(bytes: UnsafePointer<UInt8>(tag), count: tag.lengthOfBytes(using: String.Encoding.utf8))
        removeKeyWithTagData(tagData)

        // Add persistent version of the key to system keychain
        let persistKey = UnsafeMutablePointer<AnyObject?>(mutating: nil)
        let keyClass   = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate

        // Add persistent version of the key to system keychain
        let keyDict = NSMutableDictionary()
        keyDict.setObject(kSecClassKey,         forKey: kSecClass as! NSCopying)
        keyDict.setObject(tagData,              forKey: kSecAttrApplicationTag as! NSCopying)
        keyDict.setObject(kSecAttrKeyTypeRSA,   forKey: kSecAttrKeyType as! NSCopying)
        keyDict.setObject(keyData,              forKey: kSecValueData as! NSCopying)
        keyDict.setObject(keyClass,             forKey: kSecAttrKeyClass as! NSCopying)
        keyDict.setObject(NSNumber(value: true as Bool), forKey: kSecReturnPersistentRef as! NSCopying)
        keyDict.setObject(kSecAttrAccessibleAlways, forKey: kSecAttrAccessible as! NSCopying)

        var secStatus = SecItemAdd(keyDict as CFDictionary, persistKey)
        if secStatus != noErr && secStatus != errSecDuplicateItem {
            throw SwiftyRSAError(message: "Provided key couldn't be added to the keychain")
        }

        /* Only add for removal if permanent key not specified */
        if (keyId == nil) {
            keyTags.append(tagData)
        }

        // Now fetch the SecKeyRef version of the key
        var keyRef: AnyObject? = nil
        keyDict.removeObject(forKey: kSecValueData)
        keyDict.removeObject(forKey: kSecReturnPersistentRef)
        keyDict.setObject(NSNumber(value: true as Bool), forKey: kSecReturnRef as! NSCopying)
        keyDict.setObject(kSecAttrKeyTypeRSA,   forKey: kSecAttrKeyType as! NSCopying)
        secStatus = SecItemCopyMatching(keyDict as CFDictionary, &keyRef)

        guard let unwrappedKeyRef = keyRef else {
            throw SwiftyRSAError(message: "Couldn't get key reference from the keychain")
        }

        return unwrappedKeyRef as! SecKey
    }


    fileprivate func fetchKey(_ keyId: String, isPublic: Bool) throws -> SecKey {


        let tag = keyId;
        let tagData = Data(bytes: UnsafePointer<UInt8>(tag), count: tag.lengthOfBytes(using: String.Encoding.utf8))

        // Add persistent version of the key to system keychain
        let keyClass   = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate

        // Add persistent version of the key to system keychain
        let keyDict = NSMutableDictionary()
        keyDict.setObject(kSecClassKey,         forKey: kSecClass as! NSCopying)
        keyDict.setObject(tagData,              forKey: kSecAttrApplicationTag as! NSCopying)
        keyDict.setObject(kSecAttrKeyTypeRSA,   forKey: kSecAttrKeyType as! NSCopying)
        keyDict.setObject(keyClass,             forKey: kSecAttrKeyClass as! NSCopying)
        keyDict.setObject(kSecAttrAccessibleAlways, forKey: kSecAttrAccessible as! NSCopying)

        // Now fetch the SecKeyRef version of the key
        var keyRef: AnyObject? = nil
        keyDict.setObject(NSNumber(value: true as Bool), forKey: kSecReturnRef as! NSCopying)
        keyDict.setObject(kSecAttrKeyTypeRSA,   forKey: kSecAttrKeyType as! NSCopying)
        let status = SecItemCopyMatching(keyDict as CFDictionary, &keyRef)

        guard let unwrappedKeyRef = keyRef else {
            throw SwiftyRSAError(message: "fetchKeyErr. OSStatus: \(status)")
        }
        
        return unwrappedKeyRef as! SecKey
    }

    fileprivate func dataFromPEMKey(_ key: String) throws -> Data {
        let rawLines = key.components(separatedBy: "\n")
        var lines = [String]()

        for line in rawLines {
            if line == "-----BEGIN RSA PRIVATE KEY-----" ||
                line == "-----END RSA PRIVATE KEY-----"   ||
                line == "-----BEGIN PUBLIC KEY-----" ||
                line == "-----END PUBLIC KEY-----"   ||
                line == "" {
                continue
            }
            lines.append(line)
        }

        if lines.count == 0 {
            throw SwiftyRSAError(message: "Couldn't get data from PEM key: no data available after stripping headers")
        }

        // Decode base64 key
        let base64EncodedKey = lines.joined(separator: "")
        let keyData = Data(base64Encoded: base64EncodedKey, options: .ignoreUnknownCharacters)

        guard let unwrappedKeyData = keyData, unwrappedKeyData.count != 0 else {
            throw SwiftyRSAError(message: "Couldn't decode PEM key data (base64)")
        }

        return unwrappedKeyData
    }

    fileprivate func stripPublicKeyHeader(_ keyData: Data) throws -> Data {
        let count = keyData.count / MemoryLayout<CUnsignedChar>.size
        var byteArray = [CUnsignedChar](repeating: 0, count: count)
        (keyData as NSData).getBytes(&byteArray, length: keyData.count)

        var index = 0
        if byteArray[index] != 0x30 {
            throw SwiftyRSAError(message: "Invalid byte at index 0 (\(byteArray[0])) for public key header")
        }
        index += 1;

        if byteArray[index] > 0x80 {
            index += Int(byteArray[index]) - 0x80 + 1
        }
        else {
            index += 1;
        }

        let seqiod: [CUnsignedChar] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
                                       0x01, 0x05, 0x00]
        //byteArray.replaceRange(Range<Int>(start: index, end: index + seqiod.count), with: seqiod)
        byteArray.replaceSubrange(CountableRange<Int>(index ..< index + seqiod.count), with: seqiod)

        index += 15

        if byteArray[index] != 0x03 {
            throw SwiftyRSAError(message: "Invalid byte at index \(index - 1) (\(byteArray[index - 1])) for public key header")
        }
        index += 1;

        if byteArray[index] > 0x80 {
            index += Int(byteArray[index]) - 0x80 + 1
        }
        else {
            index += 1;
        }

        if byteArray[index] != 0 {
            throw SwiftyRSAError(message: "Invalid byte at index \(index - 1) (\(byteArray[index - 1])) for public key header")
        }
        index += 1;

        let test = [CUnsignedChar](byteArray[index...keyData.count - 1])

        let data = Data(bytes: UnsafePointer<UInt8>(test), count: keyData.count - index)

        return data
    }

    fileprivate func removeKeyWithTagData(_ tagData: Data) {
        let publicKey = NSMutableDictionary()
        publicKey.setObject(kSecClassKey,       forKey: kSecClass as! NSCopying)
        publicKey.setObject(kSecAttrKeyTypeRSA, forKey: kSecAttrKeyType as! NSCopying)
        publicKey.setObject(tagData,            forKey: kSecAttrApplicationTag as! NSCopying)
        SecItemDelete(publicKey as CFDictionary)
    }

    deinit {
        for tagData in keyTags {
            removeKeyWithTagData(tagData)
        }
    }
}
