//
//
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

class HomeViewController: UIViewController {
    
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
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = nil;
        
        
        if (AppDelegate.sharedInstance().debugEnabled) {
            addDebugMenu();
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
    
    @objc func infoButton() {
        
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
    
    
}
