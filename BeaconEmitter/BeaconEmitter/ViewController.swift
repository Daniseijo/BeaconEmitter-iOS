//
//  ViewController.swift
//  BeaconEmitter
//
//  Created by Daniel Seijo Sánchez on 6/9/16.
//  Copyright © 2016 Daniel Seijo Sánchez. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var majorText: UITextField!
    @IBOutlet weak var minorText: UITextField!
    @IBOutlet weak var measuredPowerText: UITextField!
    
    @IBOutlet weak var switchTransmit: UISwitch!
    
    let uuidString = "0018B4CC-1937-4981-B893-9D7191B22E35"
    
    var peripheralData:NSDictionary!
    var peripheralManager:CBPeripheralManager!
    var localBeacon:CLBeaconRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchChanging(_ sender: UISwitch) {
        if sender.isOn {
            view.endEditing(true)
            startBeacon()
        } else {
            view.endEditing(true)
            stopBeacon()
        }
    }
    
    func startBeacon() {
        if localBeacon != nil {
            stopBeacon()
        }
        
        if isValidMajorMinor(number: majorText.text!) && isValidMajorMinor(number: minorText.text!) {
            
            let uuid = UUID(uuidString: uuidString)!
            let majorValue: CLBeaconMajorValue = CLBeaconMajorValue(majorText.text!)!
            let minorValue: CLBeaconMinorValue = CLBeaconMajorValue(minorText.text!)!
            
            localBeacon = CLBeaconRegion(proximityUUID: uuid,
                                         major: majorValue,
                                         minor: minorValue,
                                         identifier: "TestBeacon")
            
            let measuredPower: NSNumber = NSNumber(value: Int(measuredPowerText.text!)!)
            
            peripheralData = localBeacon.peripheralData(withMeasuredPower: measuredPower)
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            
        } else {
            switchTransmit.setOn(false, animated: false)
            print("Not a valid Major or Minor")
        }
    }
    
    func stopBeacon() {
        if peripheralManager != nil {
            peripheralManager.stopAdvertising()
            peripheralManager = nil
        }
        peripheralData = nil
        localBeacon = nil
    }
    
    func isValidMajorMinor(number: String) -> Bool {
        if let numberInt = Int.init(number) {
            return numberInt >= 0 && numberInt < 65536
        }
        return false
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Peripheral Manager Delegate
extension ViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(peripheralData as! [String : Any]?)
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
}

