//
//  AppEventManager.swift
//  Beiwe
//
//  Created by Keary Griffin on 9/25/17.
//  Copyright © 2017 Rocketfarm Studios. All rights reserved.
//

import Foundation
import PromiseKit
import EmitterKit

class AppEventManager : DataServiceProtocol {

    static let sharedInstance = AppEventManager();
    var isCollecting: Bool = false;
    var launchTimestamp: Date = Date();
    var launchOptions: String = ""
    var launchId: String {
        return String(Int64(launchTimestamp.timeIntervalSince1970 * 1000))
    }
    var seq = 0
    var didLogLaunch: Bool = false;

    let storeType = "ios_log";
    let headers = ["timestamp", "launchId",  "memory", "battery", "event", "msg", "d1", "d2", "d3", "d4"]
    var store: DataStorage?;
    var listeners: [Listener] = [];
    var isStoreOpen: Bool {
        return store != nil;
    }

    func didLaunch(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        self.launchOptions = ""
        self.launchTimestamp = Date();
        if ((launchOptions?.index(forKey: UIApplicationLaunchOptionsKey.location)) != nil) {
            self.launchOptions = "location"
            /*
            let localNotif = UILocalNotification();
            //localNotif.fireDate = currentDate;

            let body: String = "Beiwe was Launched in the background";

            localNotif.alertBody = body;
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            UIApplication.shared.scheduleLocalNotification(localNotif);
             */

        }
        /*
        if let launchOptions = launchOptions {
            for (kind, _) in launchOptions {
                if (self.launchOptions != "") {
                    self.launchOptions = self.launchOptions + ":"
                }
                self.launchOptions = self.launchOptions + String(describing: kind)
            }
        }
         */
        log.info("AppEvent didLaunch, launchId: \(launchId), options: \(self.launchOptions)");
    }

    /*
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
     */

    func getMemory() -> String {

        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            let usedMegabytes = taskInfo.resident_size/1000000
            //print("used megabytes: \(usedMegabytes)")
            return String(usedMegabytes)
        } else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
            return ""
        }

    }

    func logAppEvent(event: String, msg: String = "", d1: String = "", d2: String = "", d3: String = "", d4: String = "") {
        if store == nil {
            return
        }
        var data: [String] = [ ];
        data.append(String(Int64(Date().timeIntervalSince1970 * 1000)));
        data.append(launchId);
        data.append(getMemory())
        data.append(String(UIDevice.current.batteryLevel))
        data.append(event);
        data.append(msg);
        data.append(d1)
        data.append(d2)
        data.append(d3)
        //data.append(d4)
        data.append(String(seq))
        seq = seq + 1


        self.store?.store(data);
        self.store?.flush();
    }

    func initCollecting() -> Bool {
        if (store != nil) {
            return true
        }
        store = DataStorageManager.sharedInstance.createStore(storeType, headers: headers);
        if (!didLogLaunch) {
            didLogLaunch = true
            var appVersion = ""
            if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                appVersion = version;
            }
            logAppEvent(event: "launch", msg: "Application launch", d1: launchOptions, d2: appVersion)
        }
        return true;
    }

    func startCollecting() {
        log.info("Turning \(storeType) collection on");
        logAppEvent(event: "collecting", msg: "Collecting Data")
        isCollecting = true
    }
    func pauseCollecting() {
        isCollecting = false
        log.info("Pausing \(storeType) collection");
        listeners = [ ];
        store!.flush();
    }
    func finishCollecting() -> Promise<Void> {
        log.info("Finish collecting \(storeType) collection");
        logAppEvent(event: "stop_collecting", msg: "Stop Collecting Data")
        pauseCollecting();
        store = nil;
        return DataStorageManager.sharedInstance.closeStore(storeType);
    }
}

