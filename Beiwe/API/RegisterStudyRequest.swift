//
//  StudyRegisterRequest.swift
//  Beiwe
//
//  Created by Keary Griffin on 3/24/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//


import Foundation
import ObjectMapper

struct RegisterStudyRequest : Mappable, ApiRequest {

    static let apiEndpoint = "/register_user/ios/"
    typealias ApiReturnType = StudySettings;

    var patientId: String?;
    var phoneNumber: String?;
    var newPassword: String?;
    var appVersion: String?;
    
    var osVersion: String?;
    var osName: String?;
    var product: String?;
    var model: String?;
    var brand = "apple";
    var manufacturer = "apple";


    init() {
        //
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            appVersion = version;
        }
        let uiDevice = UIDevice.current;
        osName = uiDevice.systemName;
        osVersion = uiDevice.systemVersion;
        product = uiDevice.model;
        model = platform();


    }
    init(patientId: String, phoneNumber: String, newPassword: String) {
        self.init();
        self.patientId = patientId;
        self.phoneNumber = phoneNumber;
        self.newPassword = newPassword;
    }

    init?(map: Map) {

    }

    // Mappable
    mutating func mapping(map: Map) {
        patientId           <- map["patient_id"]
        phoneNumber         <- map["phone_number"]
        newPassword         <- map["new_password"]
        appVersion          <- map["beiwe_version"]

        osVersion           <- map["os_version"]
        osName              <- map["device_os"]
        product             <- map["product"]
        model               <- map["model"]
        brand               <- map["brand"]
        manufacturer        <- map["manufacturer"]
    }
    
}
