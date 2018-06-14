//
//  GyroManager.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/3/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import CoreMotion
import PromiseKit

class GyroManager : DataServiceProtocol {
    let motionManager = AppDelegate.sharedInstance().motionManager;

    let headers = ["timestamp", "x", "y", "z"]
    let storeType = "gyro";
    var store: DataStorage?;
    var offset: Double = 0;

    func initCollecting() -> Bool {
        guard  motionManager.isGyroAvailable else {
            log.info("Gyro not available.  Not initializing collection");
            return false;
        }

        store = DataStorageManager.sharedInstance.createStore(storeType, headers: headers);
        // Get NSTimeInterval of uptime i.e. the delta: now - bootTime
        let uptime: TimeInterval = ProcessInfo.processInfo.systemUptime;
        // Now since 1970
        let nowTimeIntervalSince1970: TimeInterval  = Date().timeIntervalSince1970;
        // Voila our offset
        self.offset = nowTimeIntervalSince1970 - uptime;
        motionManager.gyroUpdateInterval = 0.1;

        return true;
    }

    func startCollecting() {
        log.info("Turning \(storeType) collection on");
        let queue = OperationQueue()


        motionManager.startGyroUpdates(to: queue) {
            (gyroData, error) in

            if let gyroData = gyroData {
                var data: [String] = [ ];
                let timestamp: Double = gyroData.timestamp + self.offset;
                data.append(String(Int64(timestamp * 1000)));
                //data.append(AppDelegate.sharedInstance().modelVersionId);
                data.append(String(gyroData.rotationRate.x))
                data.append(String(gyroData.rotationRate.y))
                data.append(String(gyroData.rotationRate.z))

                self.store?.store(data);
            }
        }
        AppEventManager.sharedInstance.logAppEvent(event: "gyro_on", msg: "Gyro collection on")
    }
    func pauseCollecting() {
        log.info("Pausing \(storeType) collection");
        motionManager.stopGyroUpdates();
        store?.flush();
        AppEventManager.sharedInstance.logAppEvent(event: "gyro_off", msg: "Gyro collection off")
    }
    func finishCollecting() -> Promise<Void> {
        print ("Finishing \(storeType) collecting");
        pauseCollecting();
        store = nil;
        return DataStorageManager.sharedInstance.closeStore(storeType);
    }
}
