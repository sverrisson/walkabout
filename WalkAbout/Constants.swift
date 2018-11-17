//
//  Constants.swift
//  WalkAbout
//
//  Created by Hannes Sverrisson on 14/11/2018.
//  Copyright © 2018 Hannes Sverrisson. All rights reserved.
//

import Foundation

// The following constants allocate all constants used

struct Constants {
    static let server = "https://ossur.com/"
    static let path = "api/walkabout/"
    static let dbName = "OWappDataBase"
    static let dbExtension = "sqlite"
    static let accInterval:TimeInterval = 0.1  // 100 ms minimum is ~10ms
    
    // The schema used to build the database
    // In production this should be done in code and type safe.
    static let databaseSchema = """

BEGIN TRANSACTION;

-- CREATE DATABASE Walkabout;
-- DROP TABLE IF EXISTS Client;
-- DROP TABLE IF EXISTS MSession;
-- DROP TABLE IF EXISTS Metadata;

-- Table: Client
CREATE TABLE IF NOT EXISTS Client
(
ID CHAR(36) NOT NULL PRIMARY KEY,
At datetime,
Name VARCHAR(45),
Type VARCHAR(30),
SystemVersion VARCHAR(30)
);

-- Table: Session
CREATE TABLE IF NOT EXISTS MSession
(
ID INTEGER NOT NULL PRIMARY KEY,
ClientID CHAR(36) NOT NULL REFERENCES Client(ID),
At datetime,
Name VARCHAR(55),
Description TEXT,
FOREIGN KEY (ClientID) REFERENCES Client(ID)
);

-- Table: Metadata
CREATE TABLE IF NOT EXISTS Metadata
(
ID int NOT NULL PRIMARY KEY,
SessionID INTEGER NOT NULL REFERENCES Session(ID),
At datetime,
AccX INTEGER,
AccY INTEGER,
AccZ INTEGER,
FOREIGN KEY (SessionID) REFERENCES MSession(ID)
);

COMMIT TRANSACTION;
"""
}

