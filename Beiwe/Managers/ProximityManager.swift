//
//  ProximityManager.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/2/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import PromiseKit

class ProximityManager : DataServiceProtocol {

    let storeType = "proximity";
    let headers = ["timestamp", "event"]
    var store: DataStorage?;

    @objc func proximityStateDidChange(_ notification: Notification){
        // The stage did change: plugged, unplugged, full charge...
        var data: [String] = [ ];
        data.append(String(Int64(Date().timeIntervalSince1970 * 1000)));
        data.append(UIDevice.current.proximityState ? "NearUser" : "NotNearUser");

        self.store?.store(data);
        self.store?.flush();
    }

    func initCollecting() -> Bool {
        store = DataStorageManager.sharedInstance.createStore(storeType, headers: headers);
        return true;
    }

    func startCollecting() {
        log.info("Turning \(storeType) collection on");
        UIDevice.current.isProximityMonitoringEnabled = true;
        NotificationCenter.default.addObserver(self, selector: #selector(self.proximityStateDidChange), name: NSNotification.Name.UIDeviceProximityStateDidChange, object: nil)
        AppEventManager.sharedInstance.logAppEvent(event: "proximity_on", msg: "Proximity collection on")
    }
    func pauseCollecting() {
        log.info("Pausing \(storeType) collection");
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceProximityStateDidChange, object:nil)
        store!.flush();
        AppEventManager.sharedInstance.logAppEvent(event: "proximity_off", msg: "Proximity collection off")
    }
    func finishCollecting() -> Promise<Void> {
        log.info("Finish collecting \(storeType) collection");
        pauseCollecting();
        store = nil;
        return DataStorageManager.sharedInstance.closeStore(storeType);
    }
}
