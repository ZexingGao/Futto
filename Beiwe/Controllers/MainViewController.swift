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
        
        self.navigationController?.presentTransparentNavigationBar();
        let leftImage : UIImage? = UIImage(named:"ic-user")!.withRenderingMode(.alwaysOriginal);
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(userButton))
        /*
        let rightImage : UIImage? = UIImage(named:"ic-info")!.imageWithRenderingMode(.AlwaysOriginal);
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(infoButton))
        */
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
    @objc func userButton() {
        /*
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
            });

        alertController.addAction(UIAlertAction(title: "Change Password", style: .Default) { (action) in
            self.changePassword(self)
            });

        alertController.addAction(UIAlertAction(title: "Logout", style: .Default) { (action) in
            self.logout(self);
            });

        alertController.addAction(UIAlertAction(title: "Leave Study", style: .Destructive) { (action) in
            self.leaveStudy(self);
            });

        self.presentViewController(alertController, animated: true) {
            // ...
        }
        */

        let actionController = BWXLActionController()
        actionController.settings.cancelView.backgroundColor = AppColors.highlightColor

        actionController.headerData = nil;

        actionController.addAction(Action(ActionData(title: "Change Password"), style: .default) { (action) in
            DispatchQueue.main.async {
                self.changePassword(self);
            }
            });
        actionController.addAction(Action(ActionData(title: "Call Study Staff"), style: .default) { (action) in
            DispatchQueue.main.async {
                confirmAndCallClinician(self, callAssistant: true)
            }
            });
        actionController.addAction(Action(ActionData(title: "Logout"), style: .default) { (action) in
            DispatchQueue.main.async {
                self.logout(self);
            }

            });
        actionController.addAction(Action(ActionData(title: "Leave Study"), style: .destructive) { (action) in
            DispatchQueue.main.async {
                self.leaveStudy(self);
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
    @IBAction func leaveStudy(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Leave Study", message: "Are you sure you want to leave the current study?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alertController.addAction(cancelAction)

        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            StudyManager.sharedInstance.leaveStudy().then {_ -> Void in
                AppDelegate.sharedInstance().isLoggedIn = false;
                AppDelegate.sharedInstance().transitionToCurrentAppState();
            }
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
        }
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


    @IBAction func changePassword(_ sender: AnyObject) {
        let changePasswordController = ChangePasswordViewController();
        changePasswordController.isForgotPassword = false;
        present(changePasswordController, animated: true, completion: nil);
    }
    @IBAction func logout(_ sender: AnyObject) {
        AppDelegate.sharedInstance().isLoggedIn = false;
        AppDelegate.sharedInstance().transitionToCurrentAppState();
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
