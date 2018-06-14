//
//  GenericSurveyQuestion.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/8/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//


import ObjectMapper

enum SurveyQuestionType : String {
    case InformationText = "info_text_box"
    case Slider = "slider"
    case RadioButton = "radio_button"
    case Checkbox = "checkbox"
    case FreeResponse = "free_response"
}

enum TextFieldType : String {
    case SingleLine = "SINGLE_LINE_TEXT"
    case MultiLine = "MULTI_LINE_TEXT"
    case Numeric = "NUMERIC"
}
struct GenericSurveyQuestion : Mappable  {

    var questionId = "";
    var prompt: String?
    //var questionText: String?
    var questionType: SurveyQuestionType?;
    var maxValue: Int?;
    var minValue: Int?;
    var selectionValues: [OneSelection] = [];
    var textFieldType: TextFieldType?;
    var displayIf: [String: AnyObject]?;


    init?(map: Map) {

    }

    // Mappable
    mutating func mapping(map: Map) {
        questionId <- map["question_id"]
        prompt  <- map["prompt"]
        prompt <- map["question_text"]
        questionType <- map["question_type"]
        maxValue <- (map["max"], transformJsonStringInt)
        minValue <- (map["min"], transformJsonStringInt)
        textFieldType <- map["text_field_type"]
        selectionValues <- map["answers"]
        displayIf <- map["display_if"]
    }
    
}
