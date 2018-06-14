//
//  PersistentAppUUID.swift
//  Beiwe
//
//  Created by Keary Griffin on 3/21/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import KeychainSwift;

struct PersistentAppUUID {
    static let sharedInstance = PersistentAppUUID();

    fileprivate let keychain = KeychainSwift()
    fileprivate let uuidKey = "privateAppUuid";

    let uuid: String;

    fileprivate init() {
        if let u = keychain.get(uuidKey) {
            uuid = u;
        } else {
            uuid = UUID().uuidString;
            keychain.set(uuid, forKey: uuidKey, withAccess: .accessibleAlwaysThisDeviceOnly);
        }
    }
}
