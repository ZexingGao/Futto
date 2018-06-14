//
//  NewUploadRequest.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/6/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//


import Foundation
import ObjectMapper

struct UploadRequest : Mappable, ApiRequest {

    static let apiEndpoint = "/upload/ios/"
    typealias ApiReturnType = BodyResponse;

    var fileName: String?;
    var fileData: String?;

    init(fileName: String, filePath: String) {
        self.fileName = fileName;
        /*
        do {
            self.fileData = try NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) as String;
        } catch {
            print("Error reading file for upload: \(error)");
            fileData = "";
        }
        */
    }

    init?(map: Map) {

    }

    // Mappable
    mutating func mapping(map: Map) {
        fileName         <- map["file_name"];
        fileData        <- map["file"]
    }
    
}
