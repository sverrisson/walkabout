//
//  DataStore.swift
//  WalkAbout
//
//  Created by Hannes Sverrisson on 14/11/2018.
//  Copyright © 2018 Hannes Sverrisson. All rights reserved.
//

import Foundation
import os
import SQLite

// DataStore is a singleton to isolate all data store communication from the actual database

final class DataStore {
    static let shared = DataStore()
    var dbConnection: Connection!
    var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    
    func toISODate(date: Date) -> String {
        print(dateFormatter.string(from: date))
        return dateFormatter.string(from: date)
    }
    
    init() {
        // Set up connection with sqlite and create the database if needed
        let fileMgr = FileManager.default
        if let databaseDir = try? fileMgr.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let databaseURL = databaseDir.appendingPathComponent(Constants.dbName).appendingPathExtension(Constants.dbExtension)
            // Exit if database already exists
            guard !fileMgr.fileExists(atPath: databaseURL.absoluteString) else {
                os_log("Database already exists", type: .error)
                return
            }
            // Create a database file
            do {
                dbConnection = try Connection(databaseURL.absoluteString)
                print(databaseURL.absoluteString)
                try dbConnection.execute(Constants.databaseSchema)
                storeClient()
            } catch {
                os_log("Couldn't create a new database", type: .error)
            }
        } else {
            os_log("Couldn't access database folder", type: .error)
        }
    }
    
    // Generates initial data on the client, and updates client info.
    func storeClient() {
        let uuid = UUID().uuidString
        let client = Client(id: uuid, at: Date(), name: "Joi", type: "Iphone")
        do {
            let stmt = try dbConnection.prepare("INSERT INTO Client (ID, at, name, type) VALUES (?, ?, ?, ?)")
            try stmt.run(client.id, toISODate(date: client.at), client.name, client.type)
            os_log("Client created in database", type: .error)
        } catch {
            os_log("Couldn't create Client in database", type: .error)
        }
    }
    
    func readClient() -> Client? {
        do {
            for row in try dbConnection.prepare("SELECT ID, at, name, type FROM Client") {
                return Client(id: row[0] as? String ?? "",
                              at: dateFormatter.date(from: row[1] as! String) ?? Date(),
                              name: row[2] as? String, type: row[3] as? String)
            }
            os_log("Client created in database", type: .error)
        } catch {
            os_log("Couldn't create Client in database", type: .error)
        }
        return nil
    }
    
    // Store session in the database.
    func storeSession(session: Session) {
        do {
            let stmt = try dbConnection.prepare("INSERT INTO MSession (ID, clientID, at, name, description) VALUES (?, ?, ?, ?, ?)")
            try stmt.run(Int(session.id), Int(session.clientID), toISODate(date: session.at), session.name, session.description)
            os_log("Session created in database", type: .error)
        } catch {
            os_log("Couldn't create Session in database", type: .error)
        }
    }
    
    // Store Metadata in the database.
    func storeMetadata(data: Metadata) {
        do {
            let stmt = try dbConnection.prepare("INSERT INTO Metadata (ID, sessionID, at, accX, accY, accZ) VALUES (?, ?, ?, ?, ?, ?)")
            try stmt.run(Int(data.id), Int(data.sessionID), toISODate(date: data.at), Int(data.accX), Int(data.accY), Int(data.accZ))
            os_log("Metadata created in database", type: .error)
        } catch {
            os_log("Couldn't create Metadata in database", type: .error)
        }
    }
    
    
    
}
