//
//  KeychainHandler.swift
//  Magma
//
//  Created by Robert Netzke on 12/19/23.
//

import Foundation
import KeychainAccess

enum KCError: Error {
    case duplicateEntry
    case couldNotGet
}

struct KeychainHandler {
    let keychain = Keychain(service: "com.robertnetzke.Magma")
                            .synchronizable(false)
                            .accessibility(.whenUnlockedThisDeviceOnly)
    
    func get(key: String) throws -> String {
        do {
            let value = try keychain.get(key)
            guard let unwrapped = value else { throw KCError.couldNotGet }
            return unwrapped
        } catch {
            throw KCError.couldNotGet
        }
    }
    
    func getData(key: String) throws -> Data {
        do {
            let value = try keychain.getData(key)
            guard let unwrapped = value else { throw KCError.couldNotGet }
            return unwrapped
        } catch {
            throw KCError.couldNotGet
        }
    }
    
    func doesKeyExist(key: String) -> Bool {
        if let _ = try? keychain.get(key) {
            return true
        }
        return false
    }
    
    func set(key: String, value: String) {
        keychain[string: key] = value
    }
    
    func setData(key: String, value: Data) {
        keychain[data: key] = value
    }
    
    func removeKey(key: String) {
        keychain[key] = nil
    }
    
    func removeAllKeys(keys: [String]) {
        for key in keys {
            removeKey(key: key)
        }
    }
}
