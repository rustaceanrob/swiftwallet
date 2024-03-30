//
//  NFCHandler.swift
//  Magma
//
//  Created by Robert Netzke on 2/1/24.
//

import Foundation
import CoreNFC

class NFCHandler: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    
    @Published var scannedString: String?
    var session: NFCTagReaderSession?
    var message: String?
    private var shouldRead: Bool = true
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("Session active")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print(error)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let firstTag = tags.first else {
            session.invalidate(errorMessage: "No tags found")
            return
        }
        
        session.connect(to: firstTag) { (error: Error?) in
            if error != nil {
                session.invalidate(errorMessage: "Connection failed")
                return
            }
            
            if case let NFCTag.miFare(tag) = firstTag {
                if self.shouldRead {
                    let _ = self.readNDEFMessages(from: tag, session: session)
                } else {
                    if let _ = self.message {
                        print("Message is set: \(String(describing: self.message))")
                        let _ = self.writeNDEFMessage(to: tag, session: session)
                    }
                }
                print("Found tag miFare")
            }
            
            session.alertMessage = "Tag scanned successfully"
        }
    }
    
    func writeNDEFMessage(to miFareTag: NFCMiFareTag, session: NFCTagReaderSession) {
        miFareTag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?)  in
            guard error == nil else {
                session.invalidate(errorMessage: "Error reading NDEF: \(String(describing: error))")
                return
            }
            switch ndefStatus {
            case .readWrite:
                if let message = self.message {
                    let d = message.data(using: .utf8)!
                    let m = NFCNDEFPayload(format: .nfcWellKnown, type: Data(), identifier: Data(), payload: d)
                    let message = NFCNDEFMessage(records: [m])
                    miFareTag.writeNDEF(message, completionHandler: { (error: Error?) in
                        if nil != error {
                            session.alertMessage = "Write to tag fail: \(error!)"
                            print(error ?? "An error occured")
                        }
                    })
                } else {
                    print("No message was set")
                }
                session.invalidate()
            case .notSupported:
                print("Tag not supported")
            case .readOnly:
                print("Tag is read only")
            @unknown default:
                session.invalidate()
            }
        })
    }
    
    func readNDEFMessages(from miFareTag: NFCMiFareTag, session: NFCTagReaderSession) {
        miFareTag.readNDEF { (ndefMessage: NFCNDEFMessage?, error: Error?) in
            if let error = error {
                session.invalidate(errorMessage: "Error reading NDEF: \(error.localizedDescription)")
                return
            }

            if let ndefMessage = ndefMessage {
                // Process the NDEF messages
                for record in ndefMessage.records {
                    let payload = record.payload
                    let payloadString = String(data: payload, encoding: .utf8)
                    if let payloadString = payloadString {
                        print("NDEF Record Payload: \(payloadString)")
                        DispatchQueue.main.sync {
                            self.scannedString = String(payloadString.suffix(from: payloadString.firstIndex(of: "0") ?? payloadString.endIndex))
                        }
                    }
                }
            } else {
                session.alertMessage = "No NDEF messages found on the tag"
            }
            // Invalidate the session after reading
            session.invalidate()
        }
    }
    
    func scan() {
        session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self)
        session?.alertMessage = "Hold your iPhone near the card."
        session?.begin()
    }
        
    func write(message: String) {
        self.message = message
        self.shouldRead = false
        session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self)
        session?.alertMessage = "Hold your iPhone near the card."
        session?.begin()
    }
}

