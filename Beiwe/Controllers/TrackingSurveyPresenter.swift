//
//  OnboardingManager.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/4/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import ResearchKit
//import ObjectMapper

/*
let contentJson = "{\"content\":[{\"answers\":[{\"text\":\"Never\"},{\"text\":\"Rarely\"},{\"text\":\"Occasionally\"},{\"text\":\"Frequently\"},{\"text\":\"Almost Constantly\"}],\"question_id\":\"6695d6c4-916b-4225-8688-89b6089a24d1\",\"question_text\":\"In the last 7 days, how OFTEN did you EAT BROCCOLI?\",\"question_type\":\"radio_button\"},{\"answers\":[{\"text\":\"None\"},{\"text\":\"Mild\"},{\"text\":\"Moderate\"},{\"text\":\"Severe\"},{\"text\":\"Very Severe\"}],\"display_if\":{\">\":[\"6695d6c4-916b-4225-8688-89b6089a24d1\",0]},\"question_id\":\"41d54793-dc4d-48d9-f370-4329a7bc6960\",\"question_text\":\"In the last 7 days, what was the SEVERITY of your CRAVING FOR BROCCOLI?\",\"question_type\":\"radio_button\"},{\"answers\":[{\"text\":\"Not at all\"},{\"text\":\"A little bit\"},{\"text\":\"Somewhat\"},{\"text\":\"Quite a bit\"},{\"text\":\"Very much\"}],\"display_if\":{\"and\":[{\">\":[\"6695d6c4-916b-4225-8688-89b6089a24d1\",0]},{\">\":[\"41d54793-dc4d-48d9-f370-4329a7bc6960\",0]}]},\"question_id\":\"5cfa06ad-d907-4ba7-a66a-d68ea3c89fba\",\"question_text\":\"In the last 7 days, how much did your CRAVING FOR BROCCOLI INTERFERE with your usual or daily activities, (e.g. eating cauliflower)?\",\"question_type\":\"radio_button\"},{\"display_if\":{\"or\":[{\"and\":[{\"<=\":[\"6695d6c4-916b-4225-8688-89b6089a24d1\",3]},{\"==\":[\"41d54793-dc4d-48d9-f370-4329a7bc6960\",2]},{\"<\":[\"5cfa06ad-d907-4ba7-a66a-d68ea3c89fba\",3]}]},{\"and\":[{\"<=\":[\"6695d6c4-916b-4225-8688-89b6089a24d1\",3]},{\"<\":[\"41d54793-dc4d-48d9-f370-4329a7bc6960\",3]},{\"==\":[\"5cfa06ad-d907-4ba7-a66a-d68ea3c89fba\",2]}]},{\"and\":[{\"==\":[\"6695d6c4-916b-4225-8688-89b6089a24d1\",4]},{\"<=\":[\"41d54793-dc4d-48d9-f370-4329a7bc6960\",1]},{\"<=\":[\"5cfa06ad-d907-4ba7-a66a-d68ea3c89fba\",1]}]}]},\"question_id\":\"9d7f737d-ef55-4231-e901-b3b68ca74190\",\"question_text\":\"While broccoli is a nutritious and healthful food, it's important to recognize that craving too much broccoli can have adverse consequences on your health.  If in a single day you find yourself eating broccoli steamed, stir-fried, and raw with a 'vegetable dip', you may be a broccoli addict.\\u000a\\u000aThis is an additional paragraph (following a double newline) warning you about the dangers of broccoli consumption.\",\"question_type\":\"info_text_box\"},{\"display_if\":{\"or\":[{\"and\":[{\"==\":[\"6695d6c4-916b-4225-8688-89b6089a24d1\",4]},{\"or\":[{\">=\":[\"41d54793-dc4d-48d9-f370-4329a7bc6960\",2]},{\">=\":[\"5cfa06ad-d907-4ba7-a66a-d68ea3c89fba\",2]}]}]},{\"or\":[{\">=\":[\"41d54793-dc4d-48d9-f370-4329a7bc6960\",3]},{\">=\":[\"5cfa06ad-d907-4ba7-a66a-d68ea3c89fba\",3]}]}]},\"question_id\":\"59f05c45-df67-40ed-a299-8796118ad173\",\"question_text\":\"OK, it sounds like your broccoli habit is getting out of hand.  Please call your clinician immediately.\",\"question_type\":\"info_text_box\"},{\"question_id\":\"9745551b-a0f8-4eec-9205-9e0154637513\",\"question_text\":\"How many pounds of broccoli per day could a woodchuck chuck if a woodchuck could chuck broccoli?\",\"question_type\":\"free_response\",\"text_field_type\":\"NUMERIC\"},{\"display_if\":{\"<\":[\"9745551b-a0f8-4eec-9205-9e0154637513\",10]},\"question_id\":\"cedef218-e1ec-46d3-d8be-e30cb0b2d3aa\",\"question_text\":\"That seems a little low.\",\"question_type\":\"info_text_box\"},{\"display_if\":{\"==\":[\"9745551b-a0f8-4eec-9205-9e0154637513\",10]},\"question_id\":\"64a2a19b-c3d0-4d6e-9c0d-06089fd00424\",\"question_text\":\"That sounds about right.\",\"question_type\":\"info_text_box\"},{\"display_if\":{\">\":[\"9745551b-a0f8-4eec-9205-9e0154637513\",10]},\"question_id\":\"166d74ea-af32-487c-96d6-da8d63cfd368\",\"question_text\":\"What?! No way- that's way too high!\",\"question_type\":\"info_text_box\"},{\"max\":\"5\",\"min\":\"1\",\"question_id\":\"059e2f4a-562a-498e-d5f3-f59a2b2a5a5b\",\"question_text\":\"On a scale of 1 (awful) to 5 (delicious) stars, how would you rate your dinner at Chez Broccoli Restaurant?\",\"question_type\":\"slider\"},{\"display_if\":{\">=\":[\"059e2f4a-562a-498e-d5f3-f59a2b2a5a5b\",4]},\"question_id\":\"6dd9b20b-9dfc-4ec9-cd29-1b82b330b463\",\"question_text\":\"Wow, you are a true broccoli fan.\",\"question_type\":\"info_text_box\"},{\"question_id\":\"ec0173c9-ac8d-449d-d11d-1d8e596b4ec9\",\"question_text\":\"THE END. This survey is over.\",\"question_type\":\"info_text_box\"}],\"settings\":{\"number_of_random_questions\":null,\"randomize\":false,\"randomize_with_memory\":false,\"trigger_on_first_download\":false},\"survey_type\":\"tracking_survey\",\"timings\":[[],[67500],[],[],[],[],[]]}"
*/

class TrackingSurveyPresenter : NSObject, ORKTaskViewControllerDelegate {

    static let headers = ["question id", "question type", "question text", "question answer options","answer"];
    static let timingsHeaders = ["timestamp","question id", "question type", "question text", "question answer options","answer", "event"];
    static let surveyDataType = "surveyAnswers"
    static let timingDataType = "surveyTimings"
    var retainSelf: AnyObject?;
    var surveyId: String?;
    var activeSurvey: ActiveSurvey?;
    var survey: Survey?;
    var parent: UIViewController?;
    var surveyViewController: BWORKTaskViewController?;
    var isComplete = false;
    var questionIdToQuestion: [String: GenericSurveyQuestion] = [:];
    var timingsStore: DataStorage?;
    var task: ORKTask?;
    var valueChangeHandler: Debouncer<String>?
    let timingsName: String;

    var currentQuestion: GenericSurveyQuestion? = nil;

    init(surveyId: String, activeSurvey: ActiveSurvey, survey: Survey) {
        timingsName = TrackingSurveyPresenter.timingDataType + "_" + surveyId;


        //let tempSurvey = Mapper<Survey>().map(contentJson)
        //let questions = tempSurvey!.questions;
        let questions = survey.questions;

        super.init();
        self.surveyId = surveyId;
        self.activeSurvey = activeSurvey;
        self.survey = survey;

        timingsStore = DataStorageManager.sharedInstance.createStore(timingsName, headers: TrackingSurveyPresenter.timingsHeaders)
        timingsStore!.sanitize = true;


        guard  let stepOrder = activeSurvey.stepOrder /*where questions.count > 0 */ else {
            return;
        }


        let numQuestions = survey.randomize ? min(questions.count, survey.numberOfRandomQuestions ?? 999) : questions.count;
        /*
        if (numQuestions == 0) {
            return;
        }
        */

        var hasOptionalSteps: Bool = false;
        var steps = [ORKStep]();

        for i in 0..<numQuestions {
            let question =  questions[stepOrder[i] /* i */]
            if let _ = question.displayIf {
                hasOptionalSteps = true;
            }
            if let questionType = question.questionType {
                var step: ORKStep?;
                //let questionStep = ORKQuestionStep(identifier: question.questionId);
                switch(questionType) {
                case .Checkbox, .RadioButton:
                    let questionStep = ORKQuestionStep(identifier: question.questionId);
                    step = questionStep;
                    questionStep.answerFormat = ORKTextAnswerFormat.choiceAnswerFormat(with: questionType == .RadioButton ? .singleChoice : .multipleChoice, textChoices: question.selectionValues.enumerated().map { (index, el) in
                        return ORKTextChoice(text: el.text, value: index as NSNumber)
                        })
                case .FreeResponse:
                    let questionStep = ORKQuestionStep(identifier: question.questionId);
                    step = questionStep;
                    if let textFieldType = question.textFieldType {
                        switch(textFieldType) {
                        case .SingleLine:
                            let textFormat = ORKTextAnswerFormat.textAnswerFormat();
                            textFormat.multipleLines = false;
                            questionStep.answerFormat = textFormat;
                        case .Numeric:
                            questionStep.answerFormat = ORKNumericAnswerFormat.init(style: .decimal, unit: nil, minimum: question.minValue as NSNumber?, maximum: question.maxValue as NSNumber?)
                        case .MultiLine:
                            let textFormat = ORKTextAnswerFormat.textAnswerFormat();
                            textFormat.multipleLines = true;
                            questionStep.answerFormat = textFormat;
                        }
                    }
                case .InformationText:
                    step = ORKInstructionStep(identifier: question.questionId);
                    break;
                case .Slider:
                    if let minValue = question.minValue, let maxValue = question.maxValue {
                        let questionStep = ORKQuestionStep(identifier: question.questionId);
                        step = questionStep;
                        /*
                        questionStep.answerFormat = ORKScaleAnswerFormat.init(maximumValue: maxValue, minimumValue: minValue, defaultValue: minValue, step: 1);
                        */
                        questionStep.answerFormat = BWORKScaleAnswerFormat.init(maximumValue: maxValue, minimumValue: minValue, defaultValue: minValue, step: 1);
                    }
                }
                if let step = step {
                    step.title = ""; //"Question"
                    step.text =  question.prompt
                    steps += [step];
                    questionIdToQuestion[question.questionId] = question;
                }
            }
        }

        let submitStep = ORKInstructionStep(identifier: "confirm");
        submitStep.title = "Confirm Submission";
        submitStep.text = "Thanks! You have finished answering all of the survey questions.  Pressing the submit button will now schedule your answers to be delivered";
        steps += [submitStep];

        let finishStep = ORKInstructionStep(identifier: "finished");
        finishStep.title = "Survey Completed";
        finishStep.text = StudyManager.sharedInstance.currentStudy?.studySettings?.submitSurveySuccessText;
        steps += [finishStep];

        if (!survey.randomize && hasOptionalSteps) {
            let navTask = BWNavigatableTask(identifier: "SurveyTask", steps: steps)
            for step in steps {
                let question = questionIdToQuestion[step.identifier];
                if let displayIf = question?.displayIf {
                    let navRule = BWSkipStepNavigationRule(displayIf: displayIf);
                    //navRule!.displayIf = displayIf;
                    navTask.setSkip(navRule, forStepIdentifier: step.identifier);
                }
            }
            task = navTask;
        } else {
            task = BWOrderedTask(identifier: "SurveyTask", steps: steps)
        }
    }

    func present(_ parent: UIViewController) {
        //surveyViewController.showsProgressInNavigationBar = false;

        if let activeSurvey = activeSurvey, let restorationData = activeSurvey.rkAnswers {
            surveyViewController = BWORKTaskViewController(task: task, restorationData: restorationData, delegate: self);
        } else {
            surveyViewController = BWORKTaskViewController(task: task, taskRun: nil);
            surveyViewController!.delegate = self;
        }

        //surveyViewController?.navigationController?.navigationBar.barStyle = UIBarStyle.Black

        self.parent = parent;
        self.retainSelf = self;
        surveyViewController!.displayDiscard = false;
        parent.present(surveyViewController!, animated: true, completion: nil)
        

    }

    func arrayAnswer(_ array: [String]) -> String {
        return "[" + array.joined(separator: ";") + "]"
    }

    func storeAnswer(_ identifier: String, result: ORKTaskResult) {
        guard let question = questionIdToQuestion[identifier], let stepResult = result.stepResult(forStepIdentifier: identifier) else {
            return;
        }

        var answersString = "";

        if let questionType = question.questionType {
            switch(questionType) {
            case .Checkbox, .RadioButton:
                if let results = stepResult.results {
                    if let choiceResults = results as? [ORKChoiceQuestionResult] {
                        if (choiceResults.count > 0) {
                            if let choiceAnswers = choiceResults[0].choiceAnswers {
                                var arr: [String] = [ ];
                                for a in choiceAnswers {
                                    if let num: NSNumber = a as? NSNumber {
                                        let numValue: Int = num.intValue;
                                        if (numValue >= 0 && numValue < question.selectionValues.count) {
                                            arr.append(question.selectionValues[numValue].text);
                                        } else {
                                            arr.append("");
                                        }
                                    } else {
                                        arr.append("");
                                    }
                                }
                                if (questionType == .Checkbox) {
                                    answersString = arrayAnswer(arr);
                                } else {
                                    answersString = arr.count > 0 ? arr[0] : "";
                                }
                            }
                        }
                    }
                }
            case .FreeResponse:
                if let results = stepResult.results {
                    if let freeResponses = results as? [ORKQuestionResult] {
                        if (freeResponses.count > 0) {
                            if let answer = freeResponses[0].answer {
                                answersString = String(describing: answer);
                            }
                        }
                    }
                }
            case .InformationText:
                break;
            case .Slider:
                if let results = stepResult.results {
                    if let sliderResults = results as? [ORKScaleQuestionResult] {
                        if (sliderResults.count > 0) {
                            if let answer = sliderResults[0].scaleAnswer {
                                answersString = String(describing: answer);
                            }
                        }
                    }
                }
            }
        }
        if (answersString == "" || answersString == "[]") {
            answersString = "NO_ANSWER_SELECTED";
        }
        activeSurvey?.bwAnswers[identifier] = answersString;
    }

    func questionResponse(_ question: GenericSurveyQuestion) -> (String, String, String) {
        var typeString = "";
        var optionsString = "";
        var answersString = "";

        if let questionType = question.questionType {
            typeString = questionType.rawValue
            if let answer = activeSurvey?.bwAnswers[question.questionId] {
                answersString = answer;
            } else {
                answersString = "NOT_PRESENTED";
            }
            switch(questionType) {
            case .Checkbox, .RadioButton:
                optionsString = arrayAnswer(question.selectionValues.map { return $0.text });
            case .FreeResponse:
                optionsString = "Text-field input type = " + (question.textFieldType?.rawValue ?? "");
            case .InformationText:
                answersString = "";
                break;
            case .Slider:
                if let minValue = question.minValue, let maxValue = question.maxValue {
                    optionsString = "min = " + String(minValue) + "; max = " + String(maxValue)
                }
            }
        }
        return (typeString, optionsString, answersString);
    }

    func finalizeSurveyAnswers() -> Bool {
        guard let activeSurvey = activeSurvey, let survey = activeSurvey.survey, let surveyId = surveyId, let patientId = StudyManager.sharedInstance.currentStudy?.patientId, let publicKey = StudyManager.sharedInstance.currentStudy?.studySettings?.clientPublicKey else {
            return false;
        }
        guard  let stepOrder = activeSurvey.stepOrder, survey.questions.count > 0 else {
            return false;
        }

        guard activeSurvey.bwAnswers.count > 0 else {
            log.info("No questions answered, not submitting.");
            return false;
        }

        let name = TrackingSurveyPresenter.surveyDataType + "_" + surveyId;
        let dataFile = DataStorage(type: name, headers: TrackingSurveyPresenter.headers, patientId: patientId, publicKey: publicKey, moveOnClose: true, keyRef: DataStorageManager.sharedInstance.secKeyRef);
        dataFile.sanitize = true;

        let numQuestions = survey.randomize ? min(survey.questions.count, survey.numberOfRandomQuestions ?? 999) : survey.questions.count;
        if (numQuestions == 0) {
            return false;
        }

        //     static let headers = ["question id", "question type", "question text", "question answer options","answer"];

        for i in 0..<numQuestions {
            let question =  survey.questions[stepOrder[i]];
            var data = [ question.questionId ];
            let (questionType, optionsString, answersString) = questionResponse(question);
            data.append(questionType);
            data.append(question.prompt ?? "");
            data.append(optionsString);
            data.append(answersString);
            dataFile.store(data);
        }
        dataFile.closeAndReset();
        return !dataFile.hasError;
        
    }

    static func addTimingsEvent(_ surveyId: String, event: String) {
        var timingsStore: DataStorage?;
        let timingsName: String = TrackingSurveyPresenter.timingDataType + "_" + surveyId;

        timingsStore = DataStorageManager.sharedInstance.createStore(timingsName, headers: TrackingSurveyPresenter.timingsHeaders)
        timingsStore!.sanitize = true;
        var data: [String] = [ String(Int64(Date().timeIntervalSince1970 * 1000)) ]
        data.append("");
        data.append("");
        data.append("");
        data.append("");
        data.append("");
        data.append(event);
        print("TimingsEvent: \(data.joined(separator: ","))")
        timingsStore?.store(data);
    }

    func addTimingsEvent(_ event: String, question: GenericSurveyQuestion?, forcedValue: String? = nil) {
        var data: [String] = [ String(Int64(Date().timeIntervalSince1970 * 1000)) ]
        if let question = question {
            data.append(question.questionId);
            let (questionType, optionsString, answersString) = questionResponse(question);
            data.append(questionType);
            data.append(question.prompt ?? "");
            data.append(optionsString);
            data.append(forcedValue != nil ? forcedValue! : answersString);
        } else {
            data.append("");
            data.append("");
            data.append("");
            data.append("");
            data.append(forcedValue != nil ? forcedValue! : "");
        }
        data.append(event);
        print("TimingsEvent: \(data.joined(separator: ","))")
        timingsStore?.store(data);

    }

    func possiblyAddUnpresent() {
        valueChangeHandler?.flush();
        valueChangeHandler = nil;
        if let currentQuestion = currentQuestion {
            addTimingsEvent("unpresent", question: currentQuestion);
            self.currentQuestion = nil;
        }
    }



    func closeSurvey() {
        retainSelf = nil;
        StudyManager.sharedInstance.surveysUpdatedEvent.emit(0);
        parent?.dismiss(animated: true, completion: nil);
    }

    func displaySurveyQuestion(_ identifier: String) -> Bool {
        guard let question = questionIdToQuestion[identifier], let survey = survey, let displayIf = question.displayIf else {
            return true;
        }

        return false;

    }

    /* ORK Delegates */
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        possiblyAddUnpresent();
        if (!isComplete) {
            activeSurvey?.rkAnswers = taskViewController.restorationData;
            if let study = StudyManager.sharedInstance.currentStudy {
                Recline.shared.save(study).then {_ in
                    log.info("Tracking survey Saved.");
                    }.catch {_ in
                        log.error("Error saving updated answers.");
                }
            }
        }
        closeSurvey();
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, didChange result: ORKTaskResult) {

        //print("didChangeStepId: \(taskViewController.currentStepViewController!.step!.identifier)")
        if let identifier = taskViewController.currentStepViewController!.step?.identifier {
            storeAnswer(identifier, result: result)
            let currentValue = activeSurvey!.bwAnswers[identifier];
            valueChangeHandler?.call(currentValue);
        }
        return;
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, shouldPresent step: ORKStep) -> Bool {
        possiblyAddUnpresent();
        return true;
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, learnMoreForStep stepViewController: ORKStepViewController) {
        // Present modal...
        let refreshAlert = UIAlertController(title: "Learning more!", message: "You're smart now", preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))


        taskViewController.present(refreshAlert, animated: true, completion: nil)
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, hasLearnMoreFor step: ORKStep) -> Bool {
        switch(step.identifier) {
        default: return false;
        }
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        return nil;
    }

    func taskViewControllerSupportsSaveAndRestore(_ taskViewController: ORKTaskViewController) -> Bool {
        return false;
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        /*
        stepViewController.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        stepViewController.navigationController?.presentTransparentNavigationBar()
        stepViewController.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        stepViewController.view.backgroundColor = UIColor.clearColor();
        */

        currentQuestion = nil;

        if stepViewController.continueButtonTitle == "Get Started" {
            stepViewController.continueButtonTitle = "Continue";
        }
        if let identifier = stepViewController.step?.identifier {
            switch(identifier) {
            case "finished":
                //createSurveyAnswers();
                addTimingsEvent("submitted", question: nil)
                StudyManager.sharedInstance.submitSurvey(activeSurvey!, surveyPresenter: self);
                activeSurvey?.rkAnswers = taskViewController.restorationData;
                activeSurvey?.isComplete = true;
                isComplete = true;
                StudyManager.sharedInstance.updateActiveSurveys(true);
                stepViewController.cancelButtonItem = nil;
                stepViewController.backButtonItem = nil;
            case "confirm":
                stepViewController.continueButtonTitle = "Confirm";
            default:
                if let question = questionIdToQuestion[identifier] {
                    currentQuestion = question;
                    if (activeSurvey?.bwAnswers[identifier] == nil) {
                        activeSurvey?.bwAnswers[identifier] = "";
                    }
                    var currentValue = activeSurvey!.bwAnswers[identifier];
                    addTimingsEvent("present", question: question);
                    var delay = 0.0;
                    if (question.questionType == SurveyQuestionType.Slider) {
                        delay = 0.25;
                    }
                    valueChangeHandler = Debouncer<String>(delay: delay) { [weak self] val in
                        if let strongSelf = self {
                            if (currentValue != val) {
                                currentValue = val;
                                strongSelf.addTimingsEvent("changed", question: question, forcedValue: val);
                            }
                        }
                    }
                }
            }
        }
        /*
        if (stepViewController.step?.identifier == "login") {
            stepViewController.cancelButtonItem = nil;
        }
        */
 
        //stepViewController.continueButtonTitle = "Go!"
    }

    deinit {
        DataStorageManager.sharedInstance.closeStore(timingsName)
    }
}
