//
//  ActiveSurvey.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/9/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//


import Foundation
import ObjectMapper

class ActiveSurvey : Mappable {

    var isComplete: Bool = false;
    var survey: Survey?;
    var expires: TimeInterval = 0;
    var received: TimeInterval = 0;
    var rkAnswers: Data?;
    var notification: UILocalNotification?;
    var stepOrder: [Int]?;
    var bwAnswers: [String:String] = [:]

    init(survey: Survey) {
        self.survey = survey;
    }

    required init?(map: Map) {

    }

    // Mappable
    func mapping(map: Map) {
        isComplete  <- map["is_complete"];
        survey      <- map["survey"];
        expires     <- map["expires"]
        received    <- map["received"];
        rkAnswers   <- (map["rk_answers"], transformNSData);
        bwAnswers   <- map["bk_answers"]
        notification    <- (map["notification"], transformNotification);
        stepOrder   <- map["stepOrder"];
    }

    func reset(_ survey: Survey? = nil) {
        if let survey = survey {
            self.survey = survey;
        }
        rkAnswers = nil;
        bwAnswers = [:]
        isComplete = false;
        guard let survey = survey else {
            return;
        }

        var steps = [Int](0..<survey.questions.count)
        if (survey.randomize) {
            shuffle(&steps);
        }
        log.info("shuffle steps \(steps)");

        let numQuestions = survey.randomize ? min(survey.questions.count, survey.numberOfRandomQuestions ?? 999) : survey.questions.count;
        if var order = stepOrder, survey.randomizeWithMemory && numQuestions > 0 {
            // We must have already asked a bunch of questions, otherwise stepOrder would be nil.  Remvoe them
            order.removeFirst(min(numQuestions, order.count));
            // remove all in stepOrder that are greater than count.  Could happen if questions are deleted
            // after stepOrder already set...
            order = order.filter({ $0 < survey.questions.count });
            if (order.count < numQuestions) {
                order.append(contentsOf: steps);
            }
            /* If we have a repeat in the first X steps, move it to the end and try again.. */
            log.info("proposed order \(order)");
            var index:Int=numQuestions - 1;
            while(index > 0) {
                let val = order[index];
                if order[0..<index].contains(val) {
                    order.remove(at: index);
                    order.append(val);
                } else {
                    index = index - 1;
                }
            }
            stepOrder = order;
            log.info("proposed stepOrder \(stepOrder)");
        } else {
            stepOrder = steps;
        }
        log.info("final stepOrder \(stepOrder)");
    }
}
