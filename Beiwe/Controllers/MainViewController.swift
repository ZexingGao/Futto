//
//  MainViewController.swift
//  Beiwe
//
//  Created by Keary Griffin on 3/30/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//


import UIKit
import ResearchKit
import EmitterKit
import Hakuba
import XLActionController

class MainViewController: UIViewController {

    var listeners: [Listener] = [];
    var hakuba: Hakuba!;
    var selectedSurvey: ActiveSurvey?

    @IBOutlet weak var callClinicianButton: UIButton!
    @IBOutlet weak var footerSeperator: UIView!
    @IBOutlet var activeSurveyHeader: UIView!
    @IBOutlet var emptySurveyHeader: UIView!
    @IBOutlet weak var surveyTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = nil;

        // Do any additional setup after loading the view.

        hakuba = Hakuba(tableView: surveyTableView);
        surveyTableView.backgroundView = nil;
        surveyTableView.backgroundColor = UIColor.clear;
        /*hakuba
            .registerCell(SurveyCell) */

        var clinicianText: String;
        clinicianText = StudyManager.sharedInstance.currentStudy?.studySettings?.callClinicianText ?? "Contact Clinician"
        callClinicianButton.setTitle(clinicianText, for: UIControlState())
        callClinicianButton.setTitle(clinicianText, for: UIControlState.highlighted)
        if #available(iOS 9.0, *) {
            callClinicianButton.setTitle(clinicianText, for: UIControlState.focused)
        } else {
            // Fallback on earlier versions
        }
        listeners += StudyManager.sharedInstance.surveysUpdatedEvent.on { [weak self] data in
            self?.refreshSurveys();
        }

        if (AppDelegate.sharedInstance().debugEnabled) {
            addDebugMenu();
        }

        refreshSurveys();

    }

    func refreshSurveys() {
        hakuba.removeAll();
        let section = Section() // create a new section

        hakuba
            .insert(section, atIndex: 0)
            .bump()

        var cnt = 0;
        if let activeSurveys = StudyManager.sharedInstance.currentStudy?.activeSurveys {
            let sortedSurveys = activeSurveys.sorted { (s1, s2) -> Bool in
                return s1.1.received > s2.1.received;
            }

            for (_,survey) in sortedSurveys {
                if (!survey.isComplete) {
                    let cellmodel = SurveyCellModel(activeSurvey: survey) { [weak self] cell in
                        cell.isSelected = false;
                        if let strongSelf = self, let surveyCell = cell as? SurveyCell, let surveyId = surveyCell.cellmodel?.activeSurvey.survey?.surveyId {
                            strongSelf.presentSurvey(surveyId)
                        }
                    }
                    hakuba[0].append(cellmodel)
                    cnt += 1;
                }
            }
            hakuba[0].bump();
        }
        if (cnt > 0) {
            footerSeperator.isHidden = false
            surveyTableView.tableHeaderView = activeSurveyHeader;
            surveyTableView.isScrollEnabled = true
        } else {
            footerSeperator.isHidden = true
            surveyTableView.tableHeaderView = emptySurveyHeader;
            surveyTableView.isScrollEnabled = false
        }

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addDebugMenu() {

        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(debugTap))
        tapRecognizer.numberOfTapsRequired = 2;
        tapRecognizer.numberOfTouchesRequired = 2;
        self.view.addGestureRecognizer(tapRecognizer)
    }

    @objc func debugTap(_ gestureRecognizer: UIGestureRecognizer) {
        if (gestureRecognizer.state != .ended) {
            return
        }

        refreshSurveys();

        let actionController = BWXLActionController()
        actionController.settings.cancelView.backgroundColor = AppColors.highlightColor

        actionController.headerData = nil;

        actionController.addAction(Action(ActionData(title: "Upload Data"), style: .default) { (action) in
            DispatchQueue.main.async {
                self.Upload(self)
            }
            });
        actionController.addAction(Action(ActionData(title: "Check for Surveys"), style: .default) { (action) in
            DispatchQueue.main.async {
                self.checkSurveys(self)
            }

            });

        self.present(actionController, animated: true) {

        }
        
        

    }
    
    func infoButton() {

    }
    
    @IBAction func Upload(_ sender: AnyObject) {
        StudyManager.sharedInstance.upload(false);
    }


    @IBAction func callClinician(_ sender: AnyObject) {
        // Present modal...

        confirmAndCallClinician(self);
    }

    @IBAction func checkSurveys(_ sender: AnyObject) {
        StudyManager.sharedInstance.checkSurveys();
    }
   

    func presentSurvey(_ surveyId: String) {
        guard let activeSurvey = StudyManager.sharedInstance.currentStudy?.activeSurveys[surveyId], let survey = activeSurvey.survey, let surveyType = survey.surveyType else {
            return;
        }

        switch(surveyType) {
        case .TrackingSurvey:
            TrackingSurveyPresenter(surveyId: surveyId, activeSurvey: activeSurvey, survey: survey).present(self);
        case .AudioSurvey:
            selectedSurvey = activeSurvey
            performSegue(withIdentifier: "audioQuestionSegue", sender: self)
            //AudioSurveyPresenter(surveyId: surveyId, activeSurvey: activeSurvey, survey: survey).present(self);
        }
    }


   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "audioQuestionSegue") {
            let questionController: AudioQuestionViewController = segue.destination as! AudioQuestionViewController
            questionController.activeSurvey = selectedSurvey
        }
    }



}
