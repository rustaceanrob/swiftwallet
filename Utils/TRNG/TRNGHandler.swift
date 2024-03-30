//
//  TRNGHandler.swift
//  Magma
//
//  Created by Robert Netzke on 12/19/23.
//

import Foundation

enum TRNGError: Error {
    case compromisedBytes
}

class TRNGHandler {
    func getRandomBytes(numBytes: Int) throws -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: numBytes)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        if status == errSecSuccess {
            return bytes
        }
        
        throw TRNGError.compromisedBytes
    }
}
