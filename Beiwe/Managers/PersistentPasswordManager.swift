//
//  PersistentPasswordManager
//  Beiwe
//
//  Created by Keary Griffin on 3/21/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import KeychainSwift;

struct PersistentPasswordManager {
    static let sharedInstance = PersistentPasswordManager();
    static let bundlePrefix = (Bundle.main.bundleIdentifier ?? "com.rocketarmstudios.beiwe")
    fileprivate let keychain: KeychainSwift
    fileprivate let passwordKeyPrefix = "password:";
    fileprivate let rsaKeyPrefix = PersistentPasswordManager.bundlePrefix + ".rsapk.";

    init() {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
             keychain = KeychainSwift(keyPrefix: PersistentPasswordManager.bundlePrefix + ".")
        #else
            keychain = KeychainSwift()
        #endif
    }

    fileprivate func keyForStudy(_ study: String, prefix: String) -> String {
        let key = prefix + study;
        return key;
    }

    func passwordForStudy(_ study: String = Constants.defaultStudyId) -> String? {
        return keychain.get(keyForStudy(study, prefix: passwordKeyPrefix));
    }

    func storePassword(_ password: String, study: String = Constants.defaultStudyId) {
        keychain.set(password, forKey: keyForStudy(study, prefix: passwordKeyPrefix), withAccess: .accessibleAlwaysThisDeviceOnly);
    }

    func storePublicKeyForStudy(_ publicKey: String, patientId: String, study: String = Constants.defaultStudyId) throws -> SecKey {
        let keyref = try SwiftyRSA.storePublicKey(publicKey, keyId: publicKeyName(patientId, study: study))
        return keyref
    }

    func publicKeyName(_ patientId: String, study: String = Constants.defaultStudyId) -> String {
        return keyForStudy(study, prefix: rsaKeyPrefix) + "." + patientId;
    }


}
