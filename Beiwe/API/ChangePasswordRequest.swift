//
//  ChangePasswordRequest.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/19/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//


import Foundation
import ObjectMapper

struct ChangePasswordRequest : Mappable, ApiRequest {

    static let apiEndpoint = "/set_password/ios/"
    typealias ApiReturnType = BodyResponse;

    var newPassword: String?;


    init(newPassword: String) {
        self.newPassword = newPassword;
    }

    init?(map: Map) {

    }

    // Mappable
    mutating func mapping(map: Map) {
        newPassword <- map["new_password"];
    }
    
}
