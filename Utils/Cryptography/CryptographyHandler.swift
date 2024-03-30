//
//  CryptographyHandler.swift
//  Magma
//
//  Created by Robert Netzke on 12/18/23.
//

import Foundation
import CryptoKit

struct CryptographyHandler {

    func encryptSeed(mnemonic: String) throws -> (AES.GCM.SealedBox, SymmetricKey) {
        let symmetricKey = SymmetricKey(size: .bits256)
        let dataToEncrypt = mnemonic.data(using: .utf8)!
        let sealedBox = try AES.GCM.seal(dataToEncrypt, using: symmetricKey)
        return (sealedBox, symmetricKey)
    }

    func decryptSeed(box: AES.GCM.SealedBox, key: SymmetricKey) throws -> String {
        let decryptedData = try AES.GCM.open(box, using: key)
        let mnemonic = String(data: decryptedData, encoding: .utf8)!
        return mnemonic
    }
}
