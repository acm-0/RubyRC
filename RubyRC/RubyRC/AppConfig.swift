//
//  AppConfig.swift
//  RubyRC
//
//  Created by Adam Malamy on 4/25/26.
//

// This file stores global constants for the whole app

import CoreBluetooth

struct AppConfig {
    // Throttle min and max handle positions
    static let throttleMaxAngle: Double = 60.0
    static let throttleMinAngle: Double = -45.0
    
    // Johnson Bar forward, neutral and reverse positions
    static let johnsonBarForwardAngle: Double = 210.0
    static let johnsonBarNeutralAngle: Double = 165.0
    static let johnsonBarReverseAngle: Double = 120.0
    
    // Johnson Bar Forward, Neutral and Reverse Bluetooth Codes
    static let johnsonBarForwardCode: UInt8 = 10
    static let johnsonBarNeutralCode: UInt8 = 20
    static let johnsonBarReverseCode: UInt8 = 30

    // The UUID codes for the various characteristics
    static let targetUUID = UUID(uuidString: "19b10000-e8f2-537e-4f6c-d104768a1214")!
    static let targetServiceUUID = CBUUID(string: "19b10000-e8f2-537e-4f6c-d104768a1214")
    static let redLEDUUID = CBUUID(string: "19b10001-e8f2-537e-4f6c-d104768a1214")
    static let johnsonBarUUID = CBUUID(string: "19b10002-e8f2-537e-4f6c-d104768a1214")
    static let throttleUUID = CBUUID(string: "19b10003-e8f2-537e-4f6c-d104768a1214")
    static let speedometerUUID = CBUUID(string: "19b10004-e8f2-537e-4f6c-d104768a1214")
    static let setServoUUID = CBUUID(string: "19b10005-e8f2-537e-4f6c-d104768a1214")
}
