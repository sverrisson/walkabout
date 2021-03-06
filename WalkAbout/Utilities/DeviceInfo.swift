//
// DeviceInfo.swift
// WalkAbout
//
// Created by Hannes Sverrisson on 17/11/2018.
// Copyright © 2018 Hannes Sverrisson. All rights reserved.
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
        "iPod1,1" : "iPod Touch 1G",
        "iPod2,1" : "iPod Touch 2G",
        "iPod3,1" : "iPod Touch 3G",
        "iPod4,1" : "iPod Touch 4G",
        "iPod5,1" : "iPod Touch 5G",
        "iPod7,1" : "iPod Touch 6G",
        "iPad1,1" : "iPad",
        "iPad2,1" : "iPad 2 (WiFi)",
        "iPad2,2" : "iPad 2 (GSM)",
        "iPad2,3" : "iPad 2 (CDMA)",
        "iPad2,4" : "iPad 2 (WiFi)",
        "iPad2,5" : "iPad Mini (WiFi)",
        "iPad2,6" : "iPad Mini (GSM)",
        "iPad2,7" : "iPad Mini (CDMA)",
        "iPad3,1" : "iPad 3 (WiFi)",
        "iPad3,2" : "iPad 3 (CDMA)",
        "iPad3,3" : "iPad 3 (GSM)",
        "iPad3,4" : "iPad 4 (WiFi)",
        "iPad3,5" : "iPad 4 (GSM)",
        "iPad3,6" : "iPad 4 (CDMA)",
        "iPad4,1" : "iPad Air (WiFi)",
        "iPad4,2" : "iPad Air (GSM)",
        "iPad4,3" : "iPad Air (CDMA)",
        "iPad4,4" : "iPad Mini 2 (WiFi)",
        "iPad4,5" : "iPad Mini 2 (Cellular)",
        "iPad4,6" : "iPad Mini 2 (Cellular)",
        "iPad4,7" : "iPad Mini 3 (WiFi)",
        "iPad4,8" : "iPad Mini 3 (Cellular)",
        "iPad4,9" : "iPad Mini 3 (Cellular)",
        "iPad5,1" : "iPad Mini 4 (WiFi)",
        "iPad5,2" : "iPad Mini 4 (Cellular)",
        "iPad5,3" : "iPad Air 2 (WiFi)",
        "iPad5,4" : "iPad Air 2 (Cellular)",
        "iPad6,3" : "iPad Pro 9.7-inch (WiFi)",
        "iPad6,4" : "iPad Pro 9.7-inch (Cellular)",
        "iPad6,7" : "iPad Pro 12.9-inch (WiFi)",
        "iPad6,8" : "iPad Pro 12.9-inch (Cellular)",
        "iPad6,11" : "iPad 5 (WiFi)",
        "iPad6,12" : "iPad 5 (Cellular)",
        "iPad7,1" : "iPad Pro 12.9-inch 2 (WiFi)",
        "iPad7,2" : "iPad Pro 12.9-inch 2 (Cellular)",
        "iPad7,3" : "iPad Pro 10.5-inch (WiFi)",
        "iPad7,4" : "iPad Pro 10.5-inch (Cellular)",
        "iPad7,5" : "iPad 6 (WiFi)",
        "iPad7,6" : "iPad 6 (Cellular)",
        "iPad8,1" : "iPad Pro 11-inch (WiFi)",
        "iPad8,2" : "iPad Pro 11-inch (WiFi, 1TB)",
        "iPad8,3" : "iPad Pro 11-inch (Cellular)",
        "iPad8,4" : "iPad Pro 11-inch (Cellular, 1TB)",
        "iPad8,5" : "iPad Pro 12.9-inch 3 (WiFi)",
        "iPad8,6" : "iPad Pro 12.9-inch 3 (WiFi, 1TB)",
        "iPad8,7" : "iPad Pro 12.9-inch 3 (Cellular)",
        "iPad8,8" : "iPad Pro 12.9-inch 3 (Cellular, 1TB)",
        "i386" : "Simulator",
        "x86_64" : "Simulator",
        ]
}
