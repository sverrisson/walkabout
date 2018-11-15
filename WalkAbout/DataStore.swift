//
//  DataStore.swift
//  WalkAbout
//
//  Created by Hannes Sverrisson on 14/11/2018.
//  Copyright © 2018 Hannes Sverrisson. All rights reserved.
//

import Foundation
import os

// DataStore is a singleton to isolate all data store communication from the actual database

class DataStore {
    static let shared = DataStore()
    
    init() {
        // Set up connection with sqlite
    }
    
    // Create an initial database
//    func createDatabase() {
//        let fileMgr = FileManager.default
//        if let databaseDir = try? fileMgr.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
//            let databaseURL = databaseDir.appendingPathComponent(Constants.dbName).appendingPathExtension(Constants.dbExtension)
//            // Exit if database already exists
//            guard !fileMgr.fileExists(atPath: databaseURL.absoluteString) else {
//                os_log("Database already exists", type: .error)
//                return
//            }
//            
//            // Copy from bundle
//            
//        } else {
//            os_log("Couldn't create or access database folder", type: .error)
//        }
//    }
//    
//    func openDatabase() -> OpaquePointer? {
//        var db: OpaquePointer? = nil
//        if sqlite3_open(part1DbPath, &db) == SQLITE_OK {
//            print("Successfully opened connection to database at \(part1DbPath)")
//            return db
//        } else {
//            print("Unable to open database. Verify that you created the directory described " +
//                "in the Getting Started section.")
//            PlaygroundPage.current.finishExecution()
//        }
//        
//    }
}
