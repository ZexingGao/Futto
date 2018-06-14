//
//  Study.swift
//  Beiwe
//
//  Created by Keary Griffin on 3/27/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//

import Foundation
import ObjectMapper;

class Study : ReclineObject {

    var studyId = Constants.defaultStudyId;
    var patientPhoneNumber: String = "";
    var studySettings: StudySettings?;
    var patientId: String?;
    var clinicianPhoneNumber: String?;
    var raPhoneNumber: String?;
    var nextUploadCheck: Int64?;
    var nextSurveyCheck: Int64?;
    var lastUploadSuccess: Int64 = 0
    var missedSurveyCheck: Bool = false
    var missedUploadCheck: Bool = false
    var lastBadgeCnt = 0;
    var registerDate: Int64?;
    var receivedAudioSurveys: Int = 0;
    var receivedTrackingSurveys: Int = 0;
    var submittedAudioSurveys: Int = 0;
    var submittedTrackingSurveys: Int = 0;
    var customApiUrl: String?;

    var surveys: [Survey] = [ ];
    var activeSurveys: [String:ActiveSurvey] = [:]


    var participantConsented: Bool = false;

    init(patientPhone: String, patientId: String, studySettings: StudySettings, apiUrl: String?, studyId: String = Constants.defaultStudyId) {
        super.init();
        self.patientPhoneNumber = patientPhone;
        self.studySettings = studySettings;
        self.studyId = studyId;
        self.patientId = patientId;
        self.registerDate = Int64(Date().timeIntervalSince1970);
        self.customApiUrl = apiUrl;
    }

    required init?(map: Map) {
        super.init(map: map);

    }
    
    // Mappable
    override func mapping(map: Map) {
        super.mapping(map: map);
        patientPhoneNumber     <- map["phoneNumber"];
        studySettings   <- map["studySettings"];
        studyId   <- map["studyId"];
        patientId <- map["patientId"];
        participantConsented <- map["participantConsented"];
        clinicianPhoneNumber <- map["clinicianPhoneNumber"];
        raPhoneNumber <- map["raPhoneNumber"];
        nextSurveyCheck <- (map["nextSurveyCheck"], TransformOf<Int64, NSNumber>(fromJSON: { $0?.int64Value }, toJSON: { $0.map { NSNumber(value: $0) } }))
        nextUploadCheck <- (map["nextUploadCheck"], TransformOf<Int64, NSNumber>(fromJSON: { $0?.int64Value }, toJSON: { $0.map { NSNumber(value: $0) } }))
        surveys    <- map["surveys"];
        activeSurveys   <- map["active_surveys"]
        registerDate <- (map["registerDate"], TransformOf<Int64, NSNumber>(fromJSON: { $0?.int64Value }, toJSON: { $0.map { NSNumber(value: $0) } }))
        receivedAudioSurveys <- map["receivedAudioSurveys"]
        receivedTrackingSurveys <- map["receivedTrackingSurveys"]
        submittedAudioSurveys  <- map["submittedAudioSurveys"]
        submittedTrackingSurveys <- map["submittedTrackingSurveys"]
        missedSurveyCheck <- map["missedSurveyCheck"]
        missedUploadCheck <- map["missedUploadCheck"]
        lastUploadSuccess <- map["lastUploadSuccess"]
        customApiUrl <- map["customApiUrl"]

    }

}
