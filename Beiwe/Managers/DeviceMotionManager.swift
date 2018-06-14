//
//  DeviceMotionManager.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/3/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import CoreMotion
import PromiseKit

class DeviceMotionManager : DataServiceProtocol {
    let motionManager = AppDelegate.sharedInstance().motionManager;

    let headers = ["timestamp", "roll", "pitch", "yaw",
                   "rotation_rate_x", "rotation_rate_y", "rotation_rate_z",
                   "gravity_x", "gravity_y", "gravity_z",
                   "user_accel_x", "user_accel_y", "user_accel_z",
                   "magnetic_field_calibration_accuracy", "magnetic_field_x", "magnetic_field_y", "magnetic_field_z"
                   ]
    let storeType = "devicemotion";
    var store: DataStorage?;
    var offset: Double = 0;

    func initCollecting() -> Bool {
        guard  motionManager.isDeviceMotionAvailable else {
            log.info("DeviceMotion not available.  Not initializing collection");
            return false;
        }

        store = DataStorageManager.sharedInstance.createStore(storeType, headers: headers);
        // Get NSTimeInterval of uptime i.e. the delta: now - bootTime
        let uptime: TimeInterval = ProcessInfo.processInfo.systemUptime;
        // Now since 1970
        let nowTimeIntervalSince1970: TimeInterval  = Date().timeIntervalSince1970;
        // Voila our offset
        self.offset = nowTimeIntervalSince1970 - uptime;
        motionManager.deviceMotionUpdateInterval = 0.1;
        return true;
    }

    func startCollecting() {
        log.info("Turning \(storeType) collection on");
        let queue = OperationQueue()


        motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryZVertical, to: queue) {
            (motionData, error) in

            if let motionData = motionData {
                var data: [String] = [ ];
                let timestamp: Double = motionData.timestamp + self.offset;
                data.append(String(Int64(timestamp * 1000)));
                //data.append(AppDelegate.sharedInstance().modelVersionId);
                data.append(String(motionData.attitude.roll))
                data.append(String(motionData.attitude.pitch))
                data.append(String(motionData.attitude.yaw))
                data.append(String(motionData.rotationRate.x))
                data.append(String(motionData.rotationRate.y))
                data.append(String(motionData.rotationRate.z))
                data.append(String(motionData.gravity.x))
                data.append(String(motionData.gravity.y))
                data.append(String(motionData.gravity.z))
                data.append(String(motionData.userAcceleration.x))
                data.append(String(motionData.userAcceleration.y))
                data.append(String(motionData.userAcceleration.z))
                var fieldAccuracy: String;
                switch(motionData.magneticField.accuracy) {
                case .uncalibrated:
                    fieldAccuracy = "uncalibrated"
                case .low:
                    fieldAccuracy = "low"
                case .medium:
                    fieldAccuracy = "medium"
                case .high:
                    fieldAccuracy = "high"
                default:
                    fieldAccuracy = "unknown"
                }
                data.append(fieldAccuracy)
                data.append(String(motionData.magneticField.field.x))
                data.append(String(motionData.magneticField.field.y))
                data.append(String(motionData.magneticField.field.z))

                self.store?.store(data);
            }
        }
        AppEventManager.sharedInstance.logAppEvent(event: "devicemotion_on", msg: "DeviceMotion collection on")
    }
    func pauseCollecting() {
        log.info("Pausing \(storeType) collection");
        motionManager.stopDeviceMotionUpdates();
        store?.flush();
        AppEventManager.sharedInstance.logAppEvent(event: "devicemotion_off", msg: "DeviceMotion collection off")
    }
    func finishCollecting() -> Promise<Void> {
        print ("Finishing \(storeType) collecting");
        pauseCollecting();
        store = nil;
        return DataStorageManager.sharedInstance.closeStore(storeType);
    }
}
