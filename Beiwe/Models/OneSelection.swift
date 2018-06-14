//
//  OneSelection.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/8/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//

import Foundation
import ObjectMapper

struct OneSelection : Mappable {

    var text: String = "";
    init?(map: Map) {

    }

    // Mappable
    mutating func mapping(map: Map) {
        text <- map["text"];
    }
}
