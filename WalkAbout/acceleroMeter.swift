//
//  acceleroMeter.swift
//  WalkAbout
//
//  Created by Hannes Sverrisson on 15/11/2018.
//  Copyright © 2018 Hannes Sverrisson. All rights reserved.
//

import Foundation
import CoreMotion
import os

final class AcceleroMeter {
    static let shared = AcceleroMeter()
    var motionManager = CMMotionManager()
    let measurementBuffer = 100
    var accelerometerData: [Metadata] = []
    var sessionID: Int32!
    var id: Int32 = 0
    var dataStore = DataStore.shared
    
    init() {
        os_log("AccelerometerData Init", type: .info)
        accelerometerData.reserveCapacity(measurementBuffer + 1)
        motionManager.accelerometerUpdateInterval = Constants.accInterval
        if !(motionManager.isAccelerometerAvailable) {
            os_log("AccelerometerData Not Available", type: .error)
        }
    }
    
    // Data is stored as milli-g
    fileprivate func toMillig(_ value: Double) -> Int32 {
        return Int32(value * 1000)
    }
    
    // Start a measurement for given sessionID and Metadata id (if not zero), return acceleration in a callback for ui updates
    func startFor(sessionID: Int32, from id: Int32, callback: ((CMAcceleration) -> ())? = nil) {
        accelerometerData.removeAll()
        self.sessionID = sessionID
        self.id = id
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) in
            dispatchPrecondition(condition: .onQueue(.main))
            guard let accData = accelerometerData else {
                if let error = error {
                    os_log("AccelerometerData Error: %@", type: .error, error.localizedDescription)
                } else {
                    os_log("AccelerometerData Error", type: .error)
                }
                self.stopAndSaveData()
                return
            }
            let time = Date(timeIntervalSinceReferenceDate: accData.timestamp)
            let acc = accData.acceleration
            let metaData = Metadata(id: self.id, sessionID: sessionID, at: time, accX: self.toMillig(acc.x), accY: self.toMillig(acc.y), accZ: self.toMillig(acc.z))
            self.accelerometerData.append(metaData)
            self.id += 1
            // Update the callback on the main thread
            if let callback = callback {
                DispatchQueue.main.async {
                    callback(acc)
                }
            }
            if self.accelerometerData.count > self.measurementBuffer {
                self.saveBufferedData()
            }
        }
    }
    
    // Save buffered data and clear
    fileprivate func saveBufferedData() {
        // Take a local copy so that data collection continues uninterrupted
        let dataToSave = accelerometerData
        accelerometerData.removeAll()
        // Save the data by calling dataStore on the main queue
        DispatchQueue.main.async {
            dataToSave.forEach { (metadata) in
                self.dataStore.storeMetadata(data: metadata)
            }
            os_log("AccelerometerData Saved", type: .debug)
        }
    }
    
    // Stop receiving Acc. data and save remaining data, always called from main queue
    func stopAndSaveData() {
        // This is called from the ui and thus, should be on the main queue
        dispatchPrecondition(condition: .onQueue(.main))
        // Stop receiving Acc. data
        if (motionManager.isAccelerometerActive) {
            motionManager.stopAccelerometerUpdates()
            os_log("AccelerometerData Stopped", type: .info)
        }
        if !accelerometerData.isEmpty {
            // Save and then clear
            accelerometerData.forEach { (metadata) in
                self.dataStore.storeMetadata(data: metadata)
            }
            os_log("AccelerometerData Saved", type: .debug)
            accelerometerData.removeAll()
        }
    }
}
