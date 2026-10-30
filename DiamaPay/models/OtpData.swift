//
//  OtpData.swift
//  DiamaPay
//
//  Created by bits dev team on 23/12/2025.
//


import Foundation

class OtpData: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var deviceId: String = ""
    
    func set(phoneNumber: String, deviceId: String) {
        self.phoneNumber = phoneNumber
        self.deviceId = deviceId
        print("📦 OtpData.set() called:")
        print("   phoneNumber: [\(phoneNumber)]")
        print("   deviceId: [\(deviceId)]")
    }
    
    func clear() {
        phoneNumber = ""
        deviceId = ""
    }
}