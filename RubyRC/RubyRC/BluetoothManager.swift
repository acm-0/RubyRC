//
//  BluetoothManager.swift
//  RubyRC
//
//  Created by Adam Malamy on 3/28/26.
//

import Combine
import CoreBluetooth
import Foundation

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate,
    CBPeripheralDelegate
{
    @Published var isConnected = false
    @Published var rawSpeed: UInt32 = 0

    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral?
    private var peripheral: CBPeripheral?
    private var redLEDCharacteristic: CBCharacteristic?
    private var johnsonBarCharacteristic: CBCharacteristic?
    private var throttleCharacteristic: CBCharacteristic?
    private var speedometerCharacteristic: CBCharacteristic?


    // 🔧 Replace with your peripheral UUID
    private let targetUUID = UUID(uuidString: "19b10000-e8f2-537e-4f6c-d104768a1214")!
    private let targetServiceUUID = CBUUID(string: "19b10000-e8f2-537e-4f6c-d104768a1214")
    private let redLEDUUID = CBUUID(string: "19b10001-e8f2-537e-4f6c-d104768a1214")
    private let johnsonBarUUID = CBUUID(string: "19b10002-e8f2-537e-4f6c-d104768a1214")
    private let throttleUUID = CBUUID(string: "19b10003-e8f2-537e-4f6c-d104768a1214")
    private let speedometerUUID = CBUUID(string: "19b10004-e8f2-537e-4f6c-d104768a1214")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func scan() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth not ready")
            return
        }
        print("Scanning")
        centralManager.scanForPeripherals(withServices: [targetServiceUUID])
    }

    func connect() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth not ready")
            return
        }

        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [
            targetUUID
        ])
        print(peripherals)
        if let peripheral = peripherals.first {
            targetPeripheral = peripheral
            centralManager.connect(peripheral, options: nil)
            print("Connecting to \(peripheral.name ?? "Unknown")")
        } else {
            print("Peripheral not found")
        }
    }

    func disconnect() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth not ready")
            return
        }
        guard self.isConnected == true else {
            print("No Bluetooth connection to disconnect")
            return
        }
        
        centralManager.cancelPeripheralConnection(peripheral!)
    }
    
    func clkAdjust(direction : Bool) {
        guard
            let peripheral = peripheral,
            let fwdCharacteristic = johnsonBarCharacteristic,
            let bwdCharacteristic = redLEDCharacteristic
        else {
            print("Peripheral or characteristic not ready")
            return
        }

        let characteristic = direction ? fwdCharacteristic : bwdCharacteristic
        peripheral.writeValue(Data([0x00]),
                              for: characteristic,
                              type: .withoutResponse)
    }
    
    func clkReset () {
        guard
            let peripheral = peripheral,
            let characteristic = throttleCharacteristic
        else {
            print("Peripheral or characteristic not ready")
            return
        }
        
        peripheral.writeValue(Data([0x00]),
                              for: characteristic,
                              type: .withResponse)
    }
}

extension BluetoothManager {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth ready")
            scan() // 👈 start scan here

        case .poweredOff:
            print("Bluetooth is off")

        case .unauthorized:
            print("Bluetooth unauthorized")

        case .unsupported:
            print("Bluetooth unsupported")

        default:
            print("Bluetooth not ready: \(central.state.rawValue)")
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {

        print("Found peripheral: \(peripheral.name ?? "Unnamed")")

        self.peripheral = peripheral  // ⚠️ must retain
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        DispatchQueue.main.async {
            self.isConnected = true
        }
        print("✅ Connected to peripheral")
        peripheral.delegate = self  // Set the delegate
        peripheral.discoverServices( /*[targetServiceUUID]*/nil)
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {

        guard
            let service = peripheral.services?
                .first(where: { $0.uuid == targetServiceUUID })
        else { return }

        peripheral.discoverCharacteristics(
            /*[targetCharacteristicUUID]*/nil,
            for: service
        )
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            print("Characteristic found: \(characteristic.uuid)")
            if characteristic.uuid == redLEDUUID {print("A"); redLEDCharacteristic = characteristic}
            else if characteristic.uuid == johnsonBarUUID {johnsonBarCharacteristic = characteristic}
            else if characteristic.uuid == throttleUUID {throttleCharacteristic = characteristic}
            else if characteristic.uuid == speedometerUUID {
                speedometerCharacteristic = characteristic
                if speedometerCharacteristic!.properties.contains(.notify) {
                    print("Found notify characteristic")
                    
                    // Enable notifications
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            else {print("Found no match for \(characteristic.uuid)")}
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?) {

        if let error = error {
            print("Notify error: \(error.localizedDescription)")
            return
        }

        print("Notification state updated: \(characteristic.isNotifying)")
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {

        if let error = error {
            print("Update error: \(error.localizedDescription)")
            return
        }

        guard let data = characteristic.value else { return }
//        print("Data count:", data.count)
//        print("Expected:", MemoryLayout<Int32>.size)
        if data.count == MemoryLayout<Int32>.size {
            let intValue = data.withUnsafeBytes { buffer in
                buffer.load(as: UInt32.self)
            }
            rawSpeed = intValue
        }

        
//        print("batteryLevel = \(batteryLevel)")
        // Convert to something meaningful
//        handleIncomingData(data)
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        print(
            "❌ Failed to connect:",
            error?.localizedDescription ?? "Unknown error"
        )
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.isConnected = false
        }
        scan()
        print("🔌 Disconnected")
    }
}
