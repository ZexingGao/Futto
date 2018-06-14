//
//  ReachabilityManager.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/3/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import Reachability
import PromiseKit

class ReachabilityManager : DataServiceProtocol {

    let storeType = "reachability";
    let headers = ["timestamp", "event"]
    var store: DataStorage?;

    @objc func reachabilityChanged(_ notification: Notification){
        guard let reachability = AppDelegate.sharedInstance().reachability else {
            return;
        }
        var reachState: String;
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                reachState = "wifi";
            } else {
                reachState = "cellular";
            }
        } else {
            reachState = "unreachable";
        }

        var data: [String] = [ ];
        data.append(String(Int64(Date().timeIntervalSince1970 * 1000)));
        data.append(reachState);

        self.store?.store(data);
        self.store?.flush();
    }

    func initCollecting() -> Bool {
        store = DataStorageManager.sharedInstance.createStore(storeType, headers: headers);
        return true;
    }

    func startCollecting() {
        log.info("Turning \(storeType) collection on");
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: Notification.Name.reachabilityChanged, object:nil)
        AppEventManager.sharedInstance.logAppEvent(event: "reachability_on", msg: "Reachability collection on")

    }
    func pauseCollecting() {
        log.info("Pausing \(storeType) collection");
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged, object:nil)
        store!.flush();
        AppEventManager.sharedInstance.logAppEvent(event: "reachability_off", msg: "Reachability collection off")
    }
    func finishCollecting() -> Promise<Void> {
        log.info("Finish collecting \(storeType) collection");
        pauseCollecting();
        store = nil;
        return DataStorageManager.sharedInstance.closeStore(storeType);
    }
}
