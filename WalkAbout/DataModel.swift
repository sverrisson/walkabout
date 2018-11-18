//
//  DataModel.swift
//  WalkAbout
//
//  Created by Hannes Sverrisson on 14/11/2018.
//  Copyright © 2018 Hannes Sverrisson. All rights reserved.
//

import Foundation
import SQLite

// Client stored iPhone info.  The ID is GUID.
struct Client: Codable, CustomStringConvertible {
    let id: String
    let at: Date
    let name: String
    let type: String
    let systemVersion: String
    
    var description: String {
        return "(id: \(id), at: \(at.description), name: \(name), type: \(type), version: \(systemVersion))"
    }
}

// Session stores name („Labbaði í mat“) and description („Labbaði löngu leiðina, krækti fyrir kelduna“)
struct Session: Codable, CustomDebugStringConvertible {
    let id: Int32
    let clientID: String
    let at: Date
    let name: String
    let description: String?
    let saved: Bool
    
    var debugDescription: String {
        return "(id: \(id), clientID: \(clientID), at: \(at.description), name: \(name), description: \(String(describing: description)), saved: \(saved)"
    }
}

// Metadata stores x,y,z accelerometer data collected.
struct Metadata: Codable {
    let id: Int32
    let sessionID: Int32
    let at: Date
    let accX: Int32
    let accY: Int32
    let accZ: Int32
}

// Payload is used to transfer data to server
struct Payload: Codable {
    let client: Client
    let session: Session
    let data: [Metadata]
}
