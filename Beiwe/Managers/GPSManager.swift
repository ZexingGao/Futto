//
//  GPSManager.swift
//  Beiwe
//
//  Created by Keary Griffin on 3/29/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import CoreLocation
import Darwin
import PromiseKit

protocol DataServiceProtocol {
    func initCollecting() -> Bool;
    func startCollecting();
    func pauseCollecting();
    func finishCollecting() -> Promise<Void>;
}

class DataServiceStatus {
    let onDurationSeconds: Double;
    let offDurationSeconds: Double;
    var currentlyOn: Bool;
    var nextToggleTime: Date?;
    let handler: DataServiceProtocol;

    init(onDurationSeconds: Int, offDurationSeconds: Int, handler: DataServiceProtocol) {
        self.onDurationSeconds = Double(onDurationSeconds);
        self.offDurationSeconds = Double(offDurationSeconds);
        self.handler = handler;
        currentlyOn = false;
        nextToggleTime = Date();
        // nextToggleTime = NSDate().dateByAddingTimeInterval(self.offDurationSeconds);
    }
}

class GPSManager : NSObject, CLLocationManagerDelegate, DataServiceProtocol {
    let locationManager = CLLocationManager();
    var lastLocations: [CLLocation]?;
    var isCollectingGps: Bool = false;
    var dataCollectionServices: [DataServiceStatus] = [ ];
    var gpsStore: DataStorage?;
    var areServicesRunning = false;
    static let headers = [ "timestamp", "latitude", "longitude", "altitude", "accuracy"];
    var isDeferringUpdates = false;
    var nextSurveyUpdate: TimeInterval = 0, nextServiceDate: TimeInterval = 0;
    var timer: Timer?;

    func gpsAllowed() -> Bool {
        return CLLocationManager.locationServicesEnabled() &&  CLLocationManager.authorizationStatus() == .authorizedAlways;
    }

    func startGpsAndTimer() -> Bool {

        locationManager.delegate = self;
        locationManager.activityType = CLActivityType.other;
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        };
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 99999;
        locationManager.requestAlwaysAuthorization();
        locationManager.pausesLocationUpdatesAutomatically = false;
        locationManager.startUpdatingLocation();
        locationManager.startMonitoringSignificantLocationChanges()

        if (!gpsAllowed()) {
            return false;
        }

        areServicesRunning = true
        startPollTimer(1.0)

        return true;

    }

    func stopAndClear() -> Promise<Void> {
        locationManager.stopUpdatingLocation();
        areServicesRunning = false
        clearPollTimer();
        var promise = Promise();
        for dataStatus in dataCollectionServices {
            promise = promise.then(on: DispatchQueue.global(qos: .default)) {
                dataStatus.handler.finishCollecting().then(on: DispatchQueue.global(qos: .default)) {
                    print("Returned from finishCollecting")
                    return Promise()

                    }.catch(on: DispatchQueue.global(qos: .default)) {_ in
                        print("err from finish collecting")
                }
            }
        }

        dataCollectionServices.removeAll();
        return promise;/*.then(on: DispatchQueue.global(qos: .default)) {
        } */

        /*
        var promises: [Promise<Void>] = [];
        for dataStatus in dataCollectionServices {
            promises.append(dataStatus.handler.finishCollecting().then(on: DispatchQueue.global(qos: .default)) {
                print("Returned from finishCollecting")
                return Promise()

                }.catch(on: DispatchQueue.global(qos: .default)) {_ in
                    print("err from finish collecting")
            })
        }
        dataCollectionServices.removeAll();
        return when(fulfilled: promises, on: DispatchQueue.global(qos: .default));
         */
    }

    func dispatchToServices() -> TimeInterval {
        let currentDate = Date().timeIntervalSince1970;
        var nextServiceDate = currentDate + (60 * 60);

        for dataStatus in dataCollectionServices {
            if let nextToggleTime = dataStatus.nextToggleTime {
                var serviceDate = nextToggleTime.timeIntervalSince1970;
                if (serviceDate <= currentDate) {
                    if (dataStatus.currentlyOn) {
                        dataStatus.handler.pauseCollecting();
                        dataStatus.currentlyOn = false;
                        dataStatus.nextToggleTime = Date(timeIntervalSince1970: currentDate + dataStatus.offDurationSeconds);
                    } else {
                        dataStatus.handler.startCollecting();
                        dataStatus.currentlyOn = true;
                        /* If there is no off time, we run forever... */
                        if (dataStatus.offDurationSeconds == 0) {
                            dataStatus.nextToggleTime = nil;
                        } else {
                            dataStatus.nextToggleTime = Date(timeIntervalSince1970: currentDate + dataStatus.onDurationSeconds);
                        }
                    }
                    serviceDate = dataStatus.nextToggleTime?.timeIntervalSince1970 ?? DBL_MAX;
                }
                nextServiceDate = min(nextServiceDate, serviceDate);
            }
        }
        return nextServiceDate;
    }

    @objc func pollServices() {
        log.info("Polling...");
        clearPollTimer();
        AppEventManager.sharedInstance.logAppEvent(event: "poll_service", msg: "Polling service")
        if (!areServicesRunning) {
            return
        }

        nextServiceDate = dispatchToServices();

        let currentTime = Date().timeIntervalSince1970;
        StudyManager.sharedInstance.periodicNetworkTransfers();

        if (currentTime > nextSurveyUpdate) {
            nextSurveyUpdate = StudyManager.sharedInstance.updateActiveSurveys();
        }

        setTimerForService();

    }

    func setTimerForService() {
        nextServiceDate = min(nextSurveyUpdate, nextServiceDate);
        let currentTime = Date().timeIntervalSince1970;
        let nextServiceSeconds = max(nextServiceDate - currentTime, 1.0);
        startPollTimer(nextServiceSeconds)
    }

    func clearPollTimer() {
        if let timer = timer {
            timer.invalidate();
            self.timer = nil;
        }
    }

    func resetNextSurveyUpdate(_ time: Double) {
        nextSurveyUpdate = time
        if (nextSurveyUpdate < nextServiceDate) {
            setTimerForService();
        }
    }

    func startPollTimer(_ seconds: Double) {
        clearPollTimer();
        timer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(pollServices), userInfo: nil, repeats: false)
        log.info("Timer set for: \(seconds)");
        AppEventManager.sharedInstance.logAppEvent(event: "set_timer", msg: "Set timer for \(seconds) seconds", d1: String(seconds))
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!areServicesRunning) {
            return
        }

        if (isCollectingGps) {
            recordGpsData(manager, locations: locations);
        }

        /*
        if (!isCollectingGps && !isDeferringUpdates) {
            locationManager.allowDeferredLocationUpdatesUntilTraveled(10000, timeout: nextServiceSeconds);
            isDeferringUpdates = true;
        }
        */

    }

    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        isDeferringUpdates = false;
    }

    func recordGpsData(_ manager: CLLocationManager, locations: [CLLocation]) {
        //print("Record locations: \(locations)");
        for loc in locations {
            var data: [String] = [];

            //     static let headers = [ "timestamp", "latitude", "longitude", "altitude", "accuracy", "vert_accuracy"];

            data.append(String(Int64(loc.timestamp.timeIntervalSince1970 * 1000)))
            data.append(String(loc.coordinate.latitude))
            data.append(String(loc.coordinate.longitude))
            data.append(String(loc.altitude))
            data.append(String(loc.horizontalAccuracy))
            gpsStore?.store(data);
        }
    }

    func addDataService(_ on: Int, off: Int, handler: DataServiceProtocol) {
        let dataServiceStatus = DataServiceStatus(onDurationSeconds: on, offDurationSeconds: off, handler: handler);
        if  handler.initCollecting() {
            dataCollectionServices.append(dataServiceStatus);
        }

    }

    func addDataService(_ handler: DataServiceProtocol) {
        addDataService(1, off: 0, handler: handler);
    }
    /* Data service protocol */

    func initCollecting() -> Bool {
        guard  gpsAllowed() else {
            log.error("GPS not enabled.  Not initializing collection")
            return false;
        }
        gpsStore = DataStorageManager.sharedInstance.createStore("gps", headers: GPSManager.headers);
        isCollectingGps = false;
        return true;
    }
    func startCollecting() {
        log.info("Turning GPS collection on");
        AppEventManager.sharedInstance.logAppEvent(event: "gps_on", msg: "GPS collection on")
        isCollectingGps = true;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    func pauseCollecting() {
        log.info("Pausing GPS collection");
        AppEventManager.sharedInstance.logAppEvent(event: "gps_off", msg: "GPS collection off")
        isCollectingGps = false;
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 99999;
        gpsStore?.flush();
    }
    func finishCollecting() -> Promise<Void> {
        pauseCollecting();
        isCollectingGps = false;
        gpsStore = nil;
        return DataStorageManager.sharedInstance.closeStore("gps");
    }
}
