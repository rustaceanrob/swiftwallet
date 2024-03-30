//
//  Conversions.swift
//  Magma
//
//  Created by Robert Netzke on 1/8/24.
//

import Foundation

final class Converter {
    
    static let shared = Converter()
    
    func btcToSats(btc: Float) -> Float {
        btc * 100_000_000
    }
    
    func msatToBtc(msat: UInt64) -> Float {
        Float(msat) / 100_000_000 / 1_000
    }

    func satsToBtc(sats: UInt64) -> Float {
        Float(sats) / 100_000_000
    }
    
    func msatToSat(msats: UInt64) -> Float {
        Float(msats) / 1_000
    }

    func satsToFiat(sats: UInt64, exchangeRate: Float) -> Float {
        let bitcoin = satsToBtc(sats: sats)
        return exchangeRate * bitcoin
    }
    
    func fiatToSats(exchangeRate: Float, fiat: Float) -> UInt64 {
        let bitcoinAmount = fiat / exchangeRate
        let sats = btcToSats(btc: bitcoinAmount)
        return UInt64(sats)
    }
    
    func fiatToMsats(exchangeRate: Float, fiat: Float) -> UInt64 {
        let bitcoinAmount = fiat / exchangeRate
        let sats = btcToSats(btc: bitcoinAmount)
        let msats = sats * 1_000
        return UInt64(msats)
    }
    
    func satVbToFiat(satVb: UInt64, exchangeRate: Float) -> (UInt64, Float) {
        let satEstimate = 140 * satVb
        let estimate = self.satsToFiat(sats: satEstimate, exchangeRate: exchangeRate)
        return (satVb, estimate)
    }
    
    func tickerToSymbol(ticker: String) -> String {
        if ticker == "USD" {
            return "$"
        } else if ticker == "EUR" {
            return "€"
        } else if ticker == "JPY" {
            return "¥"
        } else {
            return "$"
        }
    }
}

