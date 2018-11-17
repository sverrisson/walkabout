//
//  DataModel.swift
//  WalkAbout
//
//  Created by Hannes Sverrisson on 14/11/2018.
//  Copyright © 2018 Hannes Sverrisson. All rights reserved.
//

import Foundation
import SQLite

// Client geymir upplýsingar um símann eða ipadinn.  Nauðsynlegt að ID sé GUID eða sambærilegt sem er bundið við þetta tæki.  Viljum ekki lenda í vandræðum ef 2 clienter fá sama ID þegar við byrjum replication.  Sama á við um önnur ID.  Viljum líka vita hvað tækið heitir („Síminn hans Stjána“) og tegund („Iphone 6s“)
struct Client: Codable {
    let id: String
    let at: Date
    let name: String
    let type: String
    let systemVersion: String
}

// Session er geymir nafn („Labbaði í mat“) og lysingu („Labbaði löngu leiðina, krækti fyrir kelduna“)
struct Session: Codable {
    let id: Int32
    let clientID: String
    let at: Date
    let name: String
    let description: String?
}

// Metadata geymir x,y,z accelerometer gögnin sem er safnað.
struct Metadata: Codable {
    let id: Int32
    let sessionID: Int32
    let at: Date
    let accX: Int32
    let accY: Int32
    let accZ: Int32
}
