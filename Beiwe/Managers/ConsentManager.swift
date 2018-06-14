//
//  OnboardingManager.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/4/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import ResearchKit
//import PermissionScope


enum StepIds : String {
    case Permission = "PermissionsStep"
    case WaitForPermissions = "WaitForPermissions"
    case WarningStep = "WarningStep"
    case VisualConsent = "VisualConsentStep"
    case ConsentReview = "ConsentReviewStep"
}

class WaitForPermissionsRule : ORKStepNavigationRule {
    let nextTask: ((ORKTaskResult) -> String)
    init(nextTask: @escaping ((_ taskResult: ORKTaskResult) -> String)) {
        self.nextTask = nextTask

        super.init(coder: NSCoder())//deleted ! after NSCoder())
    }
    
    required init(coder aDecoder: NSCoder) {//deleted ? after init
        fatalError("init(coder:) has not been implemented")
    }
    override func identifierForDestinationStep(with taskResult: ORKTaskResult)  -> String {
        return self.nextTask(taskResult)
    }
}

class ConsentManager : NSObject, ORKTaskViewControllerDelegate {


    let pscope = AppDelegate.sharedInstance().pscope;
    var retainSelf: AnyObject?;
    var consentViewController: ORKTaskViewController!;
    var consentDocument: ORKConsentDocument!;

    var PermissionsStep: ORKStep {
        let instructionStep = ORKInstructionStep(identifier: StepIds.Permission.rawValue)
        instructionStep.title = "Permissions";
        //instructionStep.text = "This app requires your access to your location at all times.  It just won't work without it.  We'd also like to notify you when it's time to fill out the next survey";
        instructionStep.text = "Futto needs access to your location for the passive data gathering capabilities of this app. Futto will also send you notifications to notify you of new surveys.";
        return instructionStep;
    }

    var WarningStep: ORKStep {
        let instructionStep = ORKInstructionStep(identifier: StepIds.WarningStep.rawValue)
        instructionStep.title = "Warning";
        instructionStep.text = "Permission to access your location is required to correctly gather the data required for this study.  To participate in this study we highly recommend you go back and allow this application to access your location.";
        return instructionStep;
    }



    override init() {
        super.init();

        // Set up permissions

        var steps = [ORKStep]();


        if (!hasRequiredPermissions()) {
            steps += [PermissionsStep];
            steps += [ORKWaitStep(identifier: StepIds.WaitForPermissions.rawValue)];
            steps += [WarningStep];
        }

        consentDocument = ORKConsentDocument()
        consentDocument.title = "Futto Consent"

        let studyConsentSections = StudyManager.sharedInstance.currentStudy?.studySettings?.consentSections ?? [:];


        let overviewSection = ORKConsentSection(type: .overview);
        if let welcomeStudySection = studyConsentSections["welcome"], !welcomeStudySection.text.isEmpty {
            overviewSection.summary = welcomeStudySection.text
            if (!welcomeStudySection.more.isEmpty) {
                overviewSection.content = welcomeStudySection.more
            }
        } else {
            overviewSection.summary = "Welcome to the study"
        }

        let consentSectionTypes: [(ORKConsentSectionType, String)] = [
            (.dataGathering, "data_gathering"),
            (.privacy, "privacy"),
            (.dataUse, "data_use"),
            (.timeCommitment, "time_commitment"),
            (.studySurvey, "study_survey"),
            (.studyTasks, "study_tasks"),
            (.withdrawing, "withdrawing")
        ]


        var hasAdditionalConsent = false;
        var consentSections: [ORKConsentSection] = [overviewSection];
        for (contentSectionType, bwType) in consentSectionTypes {
            if let bwSection = studyConsentSections[bwType], !bwSection.text.isEmpty {
                hasAdditionalConsent = true;
                let consentSection = ORKConsentSection(type: contentSectionType)
                consentSection.summary = bwSection.text
                if (!bwSection.more.isEmpty) {
                    consentSection.content = bwSection.more
                }
                consentSections.append(consentSection);
            }
        }

        consentDocument.addSignature(ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature"))

        consentDocument.sections = consentSections        //TODO: signature
        
        let visualConsentStep = ORKVisualConsentStep(identifier: StepIds.VisualConsent.rawValue, document: consentDocument)
        steps += [visualConsentStep]

        //let signature = consentDocument.signatures!.first!

        if (hasAdditionalConsent) {
            let reviewConsentStep = ORKConsentReviewStep(identifier: StepIds.ConsentReview.rawValue, signature: nil, in: consentDocument)

            reviewConsentStep.text = "Review Consent"
            reviewConsentStep.reasonForConsent = "Consent to join study"

            steps += [reviewConsentStep]
        }

        let task = ORKNavigableOrderedTask(identifier: "ConsentTask", steps: steps)
        //let waitForPermissionRule = WaitForPermissionsRule(coder: NSCoder())
        //task.setNavigationRule(waitForPermissionRule!, forTriggerStepIdentifier: StepIds.WaitForPermissions.rawValue)
        task.setNavigationRule(WaitForPermissionsRule() { [weak self] taskResult -> String in
            if (self?.pscope.statusLocationAlways() == .authorized) {
                return StepIds.VisualConsent.rawValue
            } else {
                return StepIds.WarningStep.rawValue
            }

            }, forTriggerStepIdentifier: StepIds.WaitForPermissions.rawValue)
        consentViewController = ORKTaskViewController(task: task, taskRun: nil);
        consentViewController.showsProgressInNavigationBar = false;
        consentViewController.delegate = self;
        retainSelf = self;
    }

    func closeOnboarding() {
        AppDelegate.sharedInstance().transitionToCurrentAppState();
        retainSelf = nil;
    }

    func hasRequiredPermissions() -> Bool {
        return (pscope.statusNotifications() == .authorized && pscope.statusLocationAlways() == .authorized);
    }

    /* ORK Delegates */

    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        //Handle results with taskViewController.result
        //taskViewController.dismissViewControllerAnimated(true, completion: nil)
        if (reason == ORKTaskViewControllerFinishReason.discarded) {
            StudyManager.sharedInstance.leaveStudy().then { _ -> Void in
                self.closeOnboarding();
            }
        } else {
            StudyManager.sharedInstance.setConsented().then { _ -> Void in
                self.closeOnboarding();
            }
        }
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, didChange result: ORKTaskResult) {

        return;
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, shouldPresent step: ORKStep) -> Bool {
        /*
        if let identifier = StepIds(rawValue: step.identifier) {
            switch(identifier) {
            case .WarningStep:
                if (pscope.statusLocationAlways() == .Authorized) {
                    taskViewController.goForward();
                    return false;
                }
            default: break
            }
        }
        */
        return true;

    }

    func taskViewController(_ taskViewController: ORKTaskViewController, learnMoreForStep stepViewController: ORKStepViewController) {
        // Present modal...
        let refreshAlert = UIAlertController(title: "Learning more!", message: "You're smart now", preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))


        consentViewController.present(refreshAlert, animated: true, completion: nil)
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, hasLearnMoreFor step: ORKStep) -> Bool {
        return false;
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        return nil;
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        stepViewController.cancelButtonItem!.title = "Leave Study";

        if let identifier = StepIds(rawValue: stepViewController.step?.identifier ?? "") {
            switch(identifier) {
            case .WaitForPermissions:
                pscope.show({ finished, results in
                    log.info("Permissions granted");
                    if (self.hasRequiredPermissions()) {
                        stepViewController.goForward();
                    }
                    }, cancelled: { (results) in
                        log.info("Permissions cancelled");
                        stepViewController.goForward();
                })
            case .Permission:
                stepViewController.continueButtonTitle = "Permissions";
            case .WarningStep:
                if (pscope.statusLocationAlways() == .authorized) {
                    stepViewController.goForward();
                } else {
                    stepViewController.continueButtonTitle = "Continue";
                }
            case .VisualConsent:
                if (hasRequiredPermissions()) {
                    stepViewController.backButtonItem = nil;
                }
            default: break;
            }
        }

        //stepViewController.continueButtonTitle = "Go!"
    }
}
