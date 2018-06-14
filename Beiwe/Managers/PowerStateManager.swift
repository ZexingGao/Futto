//
//  PowerStateManager.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/1/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import PromiseKit
import EmitterKit

class PowerStateManager : DataServiceProtocol {

    let storeType = "powerState";
    let headers = ["timestamp", "event", "level"]
    var store: DataStorage?;
    var listeners: [Listener] = [];

    @objc func batteryStateDidChange(_ notification: Notification){
        // The stage did change: plugged, unplugged, full charge...
        var data: [String] = [ ];
        data.append(String(Int64(Date().timeIntervalSince1970 * 1000)));
        var state: String;
        switch(UIDevice.current.batteryState) {
        case .charging:
            state = "Charging";
        case .full:
            state = "Full";
        case .unplugged:
            state = "Unplugged";
        case .unknown:
            state = "PowerUnknown";
        }
        data.append(state);
        data.append(String(UIDevice.current.batteryLevel));

        self.store?.store(data);
        self.store?.flush();
    }

    func didLockUnlock(_ isLocked: Bool) {
        log.info("Lock state data changed: \(isLocked)");
        var data: [String] = [ ];
        data.append(String(Int64(Date().timeIntervalSince1970 * 1000)));
        let state: String = isLocked ? "Locked" : "Unlocked";
        data.append(state);
        data.append(String(UIDevice.current.batteryLevel));

        self.store?.store(data);
        self.store?.flush();

    }

    func initCollecting() -> Bool {
        store = DataStorageManager.sharedInstance.createStore(storeType, headers: headers);
        return true;
    }

    func startCollecting() {
        log.info("Turning \(storeType) collection on");
        UIDevice.current.isBatteryMonitoringEnabled = true;
        listeners += AppDelegate.sharedInstance().lockEvent.on { [weak self] locked in
            self?.didLockUnlock(locked);
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryStateDidChange), name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryStateDidChange), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
        AppEventManager.sharedInstance.logAppEvent(event: "powerstate_on", msg: "PowerState collection on")

    }
    func pauseCollecting() {
        log.info("Pausing \(storeType) collection");
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceBatteryStateDidChange, object:nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object:nil)
        listeners = [ ];
        store!.flush();
        AppEventManager.sharedInstance.logAppEvent(event: "powerstate_off", msg: "PowerState collection off")
    }
    func finishCollecting() -> Promise<Void> {
        log.info("Finish collecting \(storeType) collection");
        pauseCollecting();
        store = nil;
        return DataStorageManager.sharedInstance.closeStore(storeType);
    }
}
