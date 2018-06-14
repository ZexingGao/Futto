//
//  LoginViewController.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/4/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//


import UIKit
import PKHUD
import ResearchKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var callClinicianButton: UIButton!
    @IBOutlet weak var loginButton: BWBorderedButton!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.presentTransparentNavigationBar();

        var clinicianText: String;
        clinicianText = StudyManager.sharedInstance.currentStudy?.studySettings?.callClinicianText ?? "Contact Clinician"
        callClinicianButton.setTitle(clinicianText, for: UIControlState())
        callClinicianButton.setTitle(clinicianText, for: UIControlState.highlighted)
        if #available(iOS 9.0, *) {
            callClinicianButton.setTitle(clinicianText, for: UIControlState.focused)
        } else {
            // Fallback on earlier versions
        }

        password.delegate = self
        loginButton.isEnabled = false;
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        password.resignFirstResponder();
        PKHUD.sharedHUD.dimsBackground = true;
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false;

        if let password = password.text, password.characters.count > 0 {
            if (AppDelegate.sharedInstance().checkPasswordAndLogin(password)) {
                HUD.flash(.success, delay: 0.5);
                AppDelegate.sharedInstance().transitionToCurrentAppState();
            } else {
                HUD.flash(.error, delay: 1);
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginPressed(self);
        textField.resignFirstResponder();
        return true;
    }

    @objc func tap(_ gesture: UITapGestureRecognizer) {
        password.resignFirstResponder()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // Find out what the text field will be after adding the current edit
        if let text = (password.text as NSString?)?.replacingCharacters(in: range, with: string) {
            if !text.isEmpty{//Checking if the input field is not empty
                loginButton.isEnabled = true //Enabling the button
            } else {
                loginButton.isEnabled = false //Disabling the button
            }
        }

        // Return true so the text field will be changed
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true;
    }

    @IBAction func forgotPassword(_ sender: AnyObject) {
        /*
        var steps = [ORKStep]();

        let instructionStep = ORKInstructionStep(identifier: "forgotpassword")
        instructionStep.title = "Forgot Password";
        instructionStep.text = "To reset your password, please contact your clincians research assistant at " + (StudyManager.sharedInstance.currentStudy?.raPhoneNumber ?? "") + ".  Once you have called and received a temporary password, click on continue to set a new password.  Your patient ID is " + (StudyManager.sharedInstance.currentStudy?.patientId ?? "")
        steps += [instructionStep];
        steps += [ORKWaitStep(identifier: "wait")];

        let task = ORKOrderedTask(identifier: "ForgotPasswordTask", steps: steps)
        let vc = ORKTaskViewController(task: task, taskRunUUID: nil);
        vc.showsProgressInNavigationBar = false;
        vc.delegate = self;
        presentViewController(vc, animated: true, completion: nil);
        */
        let vc = ChangePasswordViewController();
        vc.isForgotPassword = true;
        vc.finished = { _ in
            self.dismiss(animated: true, completion: nil);
        }
        present(vc, animated: true, completion: nil);

    }

    /*
    @IBAction func leaveStudyPressed(sender: AnyObject) {
        StudyManager.sharedInstance.leaveStudy().then {_ -> Void in
            AppDelegate.sharedInstance().isLoggedIn = false;
            AppDelegate.sharedInstance().transitionToCurrentAppState();
        }
    }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func callClinician(_ sender: AnyObject) {
        confirmAndCallClinician(self);
    }

}
