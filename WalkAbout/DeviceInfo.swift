//
//  DeviceInfo.swift
//  WalkAbout
//
//  Created by Hannes Sverrisson on 17/11/2018.
//  Copyright © 2018 Hannes Sverrisson. All rights reserved.
//

import Foundation
import SystemConfiguration

class DeviceInfo {
    static func platform() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode
    }
    
    static func deviceType() -> String {
        if let platform = platform(), let device = deviceDict[platform] {
            return device
        }
        return "unknown"
    }
    
    static let deviceDict: Dictionary<String, String> = [
        "iPhone1,1" : "iPhone (1st generation)",
        "iPhone1,2" : "iPhone 3G",
        "iPhone2,1" : "iPhone 3GS",
        "iPhone3,1" : "iPhone 4 (GSM)",
        "iPhone3,2" : "iPhone 4 (GSM, 2nd revision)",
        "iPhone3,3" : "iPhone 4 (Verizon)",
        "iPhone4,1" : "iPhone 4S",
        "iPhone5,1" : "iPhone 5 (GSM)",
        "iPhone5,2" : "iPhone 5 (GSM+CDMA)",
        "iPhone5,3" : "iPhone 5c (GSM)",
        "iPhone5,4" : "iPhone 5c (GSM+CDMA)",
        "iPhone6,1" : "iPhone 5s (GSM)",
        "iPhone6,2" : "iPhone 5s (GSM+CDMA)",
        "iPhone7,2" : "iPhone 6",
        "iPhone7,1" : "iPhone 6 Plus",
        "iPhone8,1" : "iPhone 6s",
        "iPhone8,2" : "iPhone 6s Plus",
        "iPhone8,4" : "iPhone SE",
        "iPhone9,1" : "iPhone 7 (GSM+CDMA)",
        "iPhone9,3" : "iPhone 7 (GSM)",
        "iPhone9,2" : "iPhone 7 Plus (GSM+CDMA)",
        "iPhone9,4" : "iPhone 7 Plus (GSM)",
        "iPhone10,1" : "iPhone 8 (GSM+CDMA)",
        "iPhone10,4" : "iPhone 8 (GSM)",
        "iPhone10,2" : "iPhone 8 Plus (GSM+CDMA)",
        "iPhone10,5" : "iPhone 8 Plus (GSM)",
        "iPhone10,3" : "iPhone X (GSM+CDMA)",
        "iPhone10,6" : "iPhone X (GSM)",
        "iPhone11,1" : "iPhone XR (GSM+CDMA)",
        "iPhone11,2" : "iPhone XS (GSM+CDMA)",
        "iPhone11,3" : "iPhone XS (GSM)",
        "iPhone11,4" : "iPhone XS Max (GSM+CDMA)",
        "iPhone11,5" : "iPhone XS Max (GSM, Dual Sim, China)",
        "iPhone11,6" : "iPhone XS Max (GSM)",
        "iPhone11,8" : "iPhone XR (GSM)",
        "i386" : "Simulator",
        "x86_64" : "Simulator",
        ]
}
