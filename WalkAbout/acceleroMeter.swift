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
    var motionManager: CMMotionManager!
    var accelerometerData: [Metadata] = []
    var sessionID: Int!
    var id: Int = 0
    
    init() {
        os_log("AccelerometerData Init", type: .info)
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = Constants.accInterval
        if !(motionManager.isAccelerometerAvailable) {
            os_log("AccelerometerData Not Available", type: .error)
        }
    }
    
    func startFor(sessionID: Int) {
        self.sessionID = sessionID
        guard let motionManager = motionManager else {
            os_log("AccelerometerData Error", type: .error)
            return
        }
        motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error) in
            guard let accData = accelerometerData else {
                if let error = error {
                    os_log("AccelerometerData Error: %@", type: .error, error.localizedDescription)
                } else {
                    os_log("AccelerometerData Error", type: .error)
                }
                self.stopAndSaveData()
                return
            }
            print("joi")
            let time = Date(timeIntervalSinceReferenceDate: accData.timestamp)
            let acc = accData.acceleration
            let metaData = Metadata(id: self.id, sessionID: sessionID, at: time, accX: acc.x, accY: acc.y, accZ: acc.z)
            self.id += 1
            print(metaData)
        }
    }
    
    func stopAndSaveData() {
        os_log("AccelerometerData Stopped", type: .info)
    }
}
