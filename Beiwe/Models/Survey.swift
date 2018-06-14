//
//  Survey.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/7/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//


import Foundation
import ObjectMapper

enum SurveyTypes: String {
    case AudioSurvey = "audio_survey"
    case TrackingSurvey = "tracking_survey"
}

struct Survey : Mappable  {

    var surveyId: String?;
    var surveyType: SurveyTypes?;
    var timings: [[Int]] = [];
    var triggerOnFirstDownload: Bool = false;
    var randomize: Bool = false;
    var numberOfRandomQuestions: Int?;
    var randomizeWithMemory: Bool = false;
    var questions: [GenericSurveyQuestion] = [ ];
    var audioSurveyType: String = "compressed"
    var audioSampleRate = 44100
    var audioBitrate = 64000


    init?(map: Map) {

    }

    // Mappable
    mutating func mapping(map: Map) {
        surveyId    <- map["_id"]
        surveyType  <- map["survey_type"]
        timings     <- map["timings"];
        triggerOnFirstDownload  <- map["settings.trigger_on_first_download"]
        randomize   <- map["settings.randomize"]
        numberOfRandomQuestions <- map["settings.number_of_random_questions"]
        randomizeWithMemory     <- map["settings.randomize_with_memory"]
        audioSurveyType              <- map["settings.audio_survey_type"]
        audioSampleRate                    <- map["settings.sample_rate"]
        audioBitrate                       <- map["settings.bit_rate"]
        questions               <- map["content"];
    }
    
}
