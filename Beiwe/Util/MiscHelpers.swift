//
//  MiscHelpers.swift
//  Beiwe
//
//  Created by Keary Griffin on 3/23/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import ObjectMapper

enum BWErrors : Error {
    case ioError
}
func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func platform() -> String {
    var size : Int = 0 // as Ben Stahl noticed in his answer
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](repeating: 0, count: Int(size))
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    return String(cString: machine)
}

func shuffle<C: MutableCollection>(_ list: inout C) -> C where C.Index == Int {
    if list.count < 2 { return list }
    for i in list.startIndex ..< list.endIndex - 1 {
        let j = Int(arc4random_uniform(UInt32(list.endIndex - i))) + i
        if i != j {
            list.swapAt(i, j)
        }
    }
    return list
}

let transformNSData = TransformOf<Data, String>(fromJSON: { encoded in
    // transform value from String? to Int?
    if let str = encoded {
        return Data(base64Encoded: str, options: []);
    } else {
        return nil;
    }
    }, toJSON: { value -> String? in
        // transform value from Int? to String?
        if let value = value {
            return value.base64EncodedString(options: []);
        }
        return nil
})

let transformNotification = TransformOf<UILocalNotification, String>(fromJSON: { encoded -> UILocalNotification? in
    // transform value from String? to Int?
    if let str = encoded {
        let data = Data(base64Encoded: str, options: []);
        if let data = data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as! UILocalNotification?;
        }
    }
    return nil;
    }, toJSON: { value -> String? in
        // transform value from Int? to String?
        if let value = value {
            let data = NSKeyedArchiver.archivedData(withRootObject: value);
            return data.base64EncodedString(options:[]);
        }
        return nil
})

let transformJsonStringInt = TransformOf<Int, Any>(fromJSON: { (value: Any?) -> Int? in
    // transform value from String? to Int?
    if let value = value as? Int {
        return value;
    }
    if let value = value as? String {
        return Int(value)
    }
    return nil;
    }, toJSON: { (value: Int?) -> Int? in
        // transform value from Int? to String?
        return value;
})

class Debouncer<T>: NSObject {
    var arg: T?;
    var callback: ((_ arg: T?) -> ())
    var delay: Double
    weak var timer: Timer?

    init(delay: Double, callback: @escaping ((_ arg: T?) -> ())) {
        self.delay = delay
        self.callback = callback
    }

    func call(_ arg: T?) {
        self.arg = arg;
        if (delay == 0) {
            fireNow();
        } else {
            timer?.invalidate()
            let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(fireNow), userInfo: nil, repeats: false)
            timer = nextTimer
        }
    }

    func flush() {
        if let timer = timer {
            timer.invalidate();
            fireNow();
        }
    }

    @objc func fireNow() {
        timer = nil;
        self.callback(arg)
    }
}

func confirmAndCallClinician(_ presenter: UIViewController, callAssistant: Bool = false) {
    let msg = "Are you sure you wish to place a call now?"
    var number = StudyManager.sharedInstance.currentStudy?.clinicianPhoneNumber
    if (callAssistant) {
        //msg = "Call your study's research assistant now?"
        number = StudyManager.sharedInstance.currentStudy?.raPhoneNumber
    }
    if let phoneNumber = number, AppDelegate.sharedInstance().canOpenTel {
        if let phoneUrl = URL(string: "tel:" + phoneNumber) {
            let callAlert = UIAlertController(title: "Confirm", message: msg, preferredStyle: UIAlertControllerStyle.alert)

            callAlert.addAction(UIAlertAction(title: "Ok", style: .default) { (action: UIAlertAction!) in
                UIApplication.shared.openURL(phoneUrl)
                })
            callAlert.addAction(UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
                print("Call cancelled.");
                })
            presenter.present(callAlert, animated: true) {
                // ...
            }
        }
    }
}
