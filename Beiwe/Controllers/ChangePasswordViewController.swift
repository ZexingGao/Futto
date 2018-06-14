//
//  RegisterViewController.swift
//  Beiwe
//
//  Created by Keary Griffin on 3/23/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//


import UIKit
import Eureka
import SwiftValidator
import PKHUD
import PromiseKit

class ChangePasswordViewController: FormViewController {

    let autoValidation = false;
    let db = Recline.shared;
    var isForgotPassword = false;
    var finished: ((_ changed: Bool) -> Void)?;

    override func viewDidLoad() {
        //self.view = GradientView()
        super.viewDidLoad()

        if (isForgotPassword) {
            tableView?.backgroundColor = UIColor.white
        }
        //tableView?.backgroundColor = UIColor.clearColor()

        // Do any additional setup after loading the view.

        form +++ Section(){ section in
            if (self.isForgotPassword) {//added self. before isForgotPassword
                var header = HeaderFooterView<ForgotPasswordHeaderView>(.nibFile(name: "ForgotPasswordHeaderView", bundle: nil))
                header.onSetupView = { headerView, _ in
                    headerView.patientId.text = StudyManager.sharedInstance.currentStudy?.patientId ?? ""
                    headerView.callButton.addTarget(self, action: #selector(ChangePasswordViewController.callAssistant(_:)), for: UIControlEvents.touchUpInside)

                }
                section.header = header
            } else {
                section.header  = HeaderFooterView(stringLiteral: "Change Password")
            }
            }
            <<< SVPasswordRow("currentPassword") {
                $0.title = isForgotPassword ? "Temporary Password:" : "Current Password:"
                let placeholder: String = String($0.title!.lowercased().characters.dropLast())
                $0.placeholder = placeholder
                $0.rules = [RequiredRule()]
                $0.autoValidation = autoValidation
            }
            <<< SVPasswordRow("password") {
                $0.title = "New Password:"
                $0.placeholder = "Enter your new password";
                $0.rules = [RequiredRule(), RegexRule(regex: Constants.passwordRequirementRegex, message: Constants.passwordRequirementDescription)]
                $0.autoValidation = autoValidation
            }
            <<< SVPasswordRow("confirmPassword") {
                $0.title = "Confirm Password:"
                $0.placeholder = "Confirm your new password";
                $0.rules = [RequiredRule(), MinLengthRule(length: 1)]
                $0.autoValidation = autoValidation
            }
            <<< ButtonRow() {
                $0.title = "Change"
                }
                .onCellSelection {
                    [unowned self] cell, row in
                    if (self.form.validateAll()) {
                        PKHUD.sharedHUD.dimsBackground = true;
                        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false;
                        HUD.show(.progress);
                        let formValues = self.form.values();
                        let newPassword: String? = formValues["password"] as! String?;
                        let currentPassword: String? = formValues["currentPassword"] as! String?;
                        if let newPassword = newPassword, let currentPassword = currentPassword {
                            let changePasswordRequest = ChangePasswordRequest(newPassword: newPassword);
                            ApiManager.sharedInstance.makePostRequest(changePasswordRequest, password: currentPassword).then {
                                (body, code) -> Void in
                                log.info("Password changed");
                                PersistentPasswordManager.sharedInstance.storePassword(newPassword);
                                HUD.flash(.success, delay: 1);
                                if let finished = self.finished {
                                    finished(true);
                                } else {
                                    self.presentingViewController?.dismiss(animated: true, completion: nil);
                                }
                            }.catch { error -> Void in
                                    log.info("error received from change password: \(error)");
                                    let delay = 2.0;
                                    var err: HUDContentType;
                                    switch error {
                                    case ApiErrors.failedStatus(let code):
                                        switch code {
                                        case 403, 401:
                                            err = .labeledError(title: "Failed", subtitle: "Incorrect Password");
                                        default:
                                            err = .labeledError(title: "Failed", subtitle: "Communication error");
                                        }
                                    default:
                                        err = .labeledError(title: "Failed", subtitle: "Communication error");
                                    }
                                    HUD.flash(err, delay: delay)
                            }
                        }
                    } else {
                        print("Bad validation.");
                    }
                }
            <<< ButtonRow() {
                $0.title = "Cancel";
                }.onCellSelection { [unowned self] cell, row in
                    if let finished = self.finished {
                        finished(false);
                    } else {
                        self.presentingViewController?.dismiss(animated: true, completion: nil);
                    }
        }
        let passwordRow: SVPasswordRow? = form.rowBy(tag: "password");
        let confirmRow: SVPasswordRow? = form.rowBy(tag: "confirmPassword");
        confirmRow!.rules = [ConfirmationRule(confirmField: passwordRow!.cell.textField)]



    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func callAssistant(_ sender:UIButton!) {
        confirmAndCallClinician(self, callAssistant: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
