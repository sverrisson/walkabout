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
import UIKit

// DataStore is a singleton to isolate all data store communication from the actual database

final class DataStore {
    static let shared = DataStore()
    private var dbConnection: Connection!
    private var backgroundTaskID: UIBackgroundTaskIdentifier?
    private var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    
    private func toISODate(date: Date) -> String {
        print(dateFormatter.string(from: date))
        return dateFormatter.string(from: date)
    }
    
    private init() {
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
        let name = UIDevice.current.name
        let type = DeviceInfo.deviceType()
        let systemVersion = UIDevice.current.systemVersion
        let client = Client(id: uuid, at: Date(), name: name, type: type, systemVersion: systemVersion)
        do {
            let stmt = try dbConnection.prepare("INSERT INTO Client (ID, At, Name, Type, SystemVersion) VALUES (?, ?, ?, ?, ?)")
            try stmt.run(client.id,
                         toISODate(date: client.at),
                         client.name,
                         client.type,
                         client.systemVersion)
            os_log("Client created in database", type: .error)
        } catch {
            os_log("Couldn't create Client in database", type: .error)
            fatalError()
        }
    }
    
    func readClient() -> Client? {
        do {
            for row in try dbConnection.prepare("SELECT ID, At, Name, Type, SystemVersion FROM Client") {
                return Client(id: row[0] as? String ?? "",
                              at: dateFormatter.date(from: row[1] as! String) ?? Date(),
                              name: (row[2] ?? "") as! String,
                              type: (row[3] ?? "") as! String,
                              systemVersion: (row[4] ?? "") as! String)
            }
            os_log("Client read from database", type: .error)
        } catch {
            os_log("Couldn't read Client in database", type: .error)
            fatalError()
        }
        return nil
    }
    
    // Store session in the database.
    func storeSession(session: Session) {
        do {
            let stmt = try dbConnection.prepare("INSERT INTO MSession (ID, ClientID, At, Name, Description, Saved) VALUES (?, ?, ?, ?, ?, ?)")
            try stmt.run(Int(session.id),
                         session.clientID,
                         toISODate(date: session.at),
                         session.name,
                         session.description,
                         session.saved ? 1 : 0)
            os_log("Session created in database", type: .error)
        } catch {
            os_log("Couldn't create Session in database", type: .error)
            fatalError()
        }
    }
    
    func readSession() -> Session? {
        do {
            for row in try dbConnection.prepare("SELECT ID, ClientID, At, Name, Description, Saved FROM MSession") {
                return Session(id: row[0] as! Int32,
                               clientID: row[1] as! String,
                               at: dateFormatter.date(from: row[2] as! String) ?? Date(),
                               name: row[3] as! String,
                               description: (row[4] ?? "") as? String,
                               saved: ((row[5] ?? 0) as! Int)==1 ? true : false)
            }
            os_log("Session read from database", type: .error)
        } catch {
            os_log("Couldn't read Session from database", type: .error)
            fatalError()
        }
        return nil
    }
    
    // Store Metadata in the database.
    func storeMetadata(data: Metadata) {
        do {
            let stmt = try dbConnection.prepare("INSERT INTO Metadata (ID, SessionID, At, AccX, AccY, AccZ) VALUES (?, ?, ?, ?, ?, ?)")
            try stmt.run(Int(data.id),
                         Int(data.sessionID),
                         toISODate(date: data.at),
                         Int(data.accX),
                         Int(data.accY),
                         Int(data.accZ))
            os_log("Metadata created in database", type: .error)
        } catch {
            os_log("Couldn't create Metadata in database", type: .error)
            fatalError()
        }
    }
    
    func readMetadataFor(sessionID: Int32) -> [Metadata]? {
        do {
            var metadata: [Metadata] = []
            let stmts = try dbConnection.prepare("SELECT * FROM Metadata WHERE SessionID = ? LIMIT 2400", Int(sessionID))
            os_log("Metadata read from database", type: .error)
            stmts.forEach { (row) in
                let meta = Metadata(id: row[0] as! Int32,
                                    sessionID: row[1] as! Int32,
                                    at: dateFormatter.date(from: row[2] as! String) ?? Date(),
                                    accX: row[3] as! Int32,
                                    accY: row[4] as! Int32,
                                    accZ: row[5] as! Int32)
                metadata.append(meta)
            }
            return metadata
        } catch {
            os_log("Couldn't create Metadata in database", type: .error)
            fatalError()
        }
    }
    
    // Sends data to the cloud for the given session and deletes the data if successful
    func sendToCloud(session: Session, callback: @escaping (Bool) -> ()) {
        os_log("Send data to API server in background if needed", type: .info)
        DispatchQueue.global().async {
            let networkClient = NetworkClient.shared
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Finish Network Upload") {
                // End the task if time expires.
                DispatchQueue.main.async {
                    callback(false)
                }
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
            }
            if let client = self.readClient(), let meta = self.readMetadataFor(sessionID: session.id) {
                let payload = Payload(client: client, session: session, data: meta)
                let encoder = JSONEncoder()
                if let data = try? encoder.encode(payload) {
                    // Send the data synchronously.
                    let result = networkClient.sendDataSynchronously(data)
                    DispatchQueue.main.async {
                        callback(result)
                    }
                }
            }
            
            // End the task assertion.
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
    }
    
}
