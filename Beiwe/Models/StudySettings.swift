//
//  StudySettings.swift
//  Beiwe
//
//  Created by Keary Griffin on 3/23/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//


import Foundation
import ObjectMapper;

/*
 Example JSON:

 { client_public_key: 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn4ynh9zr7TZJBDoWx9TB78Mo7mAL4hSoLPEEGoZdEffvpKcXmY6qZOzXU6CzODts/3XXbqFHQrPKY9EnaumifeKpzIJZDRf6jUZD5SOFACLTH6u6+/2KiZKaGJ591GJTH4r/1LxvvIEAr2XxK9qx49RKlBl3dGPYn+7079wzV9mhdrYbqLgJCgZr0TqSiJvVYbGDuESnPZ5/1doAaFWnL8JILHv/Hf6HBTroePZmEsu00r2PQiEURtUWt76auccwKPzG+I6wqKfFR4o4uUovAZjxUledpvucXwOi10jCVK70MEVUTGKYp6/m2LyEdtGrKImMja/sAuoMU9qlaNPsaQIDAQAB',
 device_settings:
 { about_page_text: 'The Beiwe application runs on your phone and helps researchers collect information about your behaviors. Beiwe may ask you to fill out short surveys or to record your voice. It may collect information about your location (using phone GPS) and how much you move (using phone accelerometer). Beiwe may also monitor how much you use your phone for calling and texting and keep track of the people you communicate with. Importantly, Beiwe never records the names or phone numbers of anyone you communicate with. While it can tell if you call the same person more than once, it does not know who that person is. Beiwe also does not record the content of your text messages or phone calls. Beiwe may keep track of the different Wi-Fi networks and Bluetooth devices around your phone, but the names of those networks are replaced with random codes.\r\n\r\nAlthough Beiwe collects large amounts of data, the data is processed to protect your privacy. This means that it does not know your name, your phone number, or anything else that could identify you. Beiwe only knows you by an identification number. Because Beiwe does not know who you are, it cannot communicate with your clinician if you are ill or in danger. Researchers will not review the data Beiwe collects until the end of the study. To make it easier for you to connect with your clinician, the \'Call my Clinician\' button appears at the bottom of every page.\r\n\r\nBeiwe was conceived and designed by Dr. Jukka-Pekka \'JP\' Onnela at the Harvard T.H. Chan School of Public Health. Development of the Beiwe smartphone application and data analysis software is funded by NIH grant 1DP2MH103909-01 to Dr. Onnela. The smartphone application was built by Zagaran, Inc., in Cambridge, Massachusetts.',
 accelerometer: true,
 accelerometer_off_duration_seconds: 300,
 accelerometer_on_duration_seconds: 300,
 bluetooth: true,
 bluetooth_global_offset_seconds: 150,
 bluetooth_on_duration_seconds: 300,
 bluetooth_total_duration_seconds: 0,
 call_clinician_button_text: 'Call My Clinician',
 calls: true,
 check_for_new_surveys_frequency_seconds: 21600,
 consent_form_text: ' I have read and understood the information about the study and all of my questions about the study have been answered by the study researchers.',
 create_new_data_files_frequency_seconds: 900,
 gps: true,
 gps_off_duration_seconds: 300,
 gps_on_duration_seconds: 300,
 power_state: true,
 seconds_before_auto_logout: 300,
 survey_submit_success_toast_text: 'Thank you for completing the survey.  A clinician will not see your answers immediately, so if you need help or are thinking about harming yourself, please contact your clinician.  You can also press the "Call My Clinician" button.',
 texts: true,
 upload_data_files_frequency_seconds: 3600,
 voice_recording_max_time_length_seconds: 300,
 wifi: true,
 wifi_log_frequency_seconds: 300 } },
 
 */

struct ConsentSection: Mappable {

    var text: String = "";
    var more: String = "";

    init?(map: Map) {

    }

    // Mappable
    mutating func mapping(map: Map) {
        text    <- map["text"]
        more    <- map["more"]
    }
}
struct StudySettings : Mappable {

    var clientPublicKey: String?;
    var aboutPageText = "";
    var accelerometer  = false;
    var accelerometerOffDurationSeconds = 300;
    var accelerometerOnDurationSeconds = 0;
    var bluetooth = false;
    var bluetoothGlobalOffsetSeconds = 0;
    var bluetoothOnDurationSeconds = 0;
    var bluetoothTotalDurationSeconds = 0;
    var callClinicianText = "Call My Clinician";
    var calls = false;
    var checkForNewSurveysFreqSeconds = 21600;
    var consentFormText = "I have read and understood the information about the study and all of my questions about the study have been answered by the study researchers.";
    var createNewDataFileFrequencySeconds = 900;
    var gps = false;
    var gpsOffDurationSeconds = 300;
    var gpsOnDurationSeconds = 0;
    var powerState = false;
    var secondsBeforeAutoLogout = 300;
    var submitSurveySuccessText = "Thank you for completing the survey.  A clinician will not see your answers immediately, so if you need help or are thinking about harming yourself, please contact your clinician.  You can also press the \"Call My Clinician\" button.";
    var texts = false;
    var uploadDataFileFrequencySeconds = 3600;
    var voiceRecordingMaxLengthSeconds = 300;
    var wifi = false;
    var wifiLogFrequencySeconds = 300;
    var proximity = false;
    var magnetometer = false;
    var magnetometerOffDurationSeconds = 300;
    var magnetometerOnDurationSeconds = 0;
    var gyro = false;
    var gyroOffDurationSeconds = 300;
    var gyroOnDurationSeconds = 0;
    var motion = false;
    var motionOffDurationSeconds = 300;
    var motionOnDurationSeconds = 0;
    var reachability = false;
    var uploadOverCellular = false;
    var consentSections: [String:ConsentSection] = [:];

    init?(map: Map) {

    }

    // Mappable
    mutating func mapping(map: Map) {
        clientPublicKey                 <- map["client_public_key"];
        aboutPageText                   <- map["device_settings.about_page_text"];
        accelerometer                   <- map["device_settings.accelerometer"];
        accelerometerOffDurationSeconds <- map["device_settings.accelerometer_off_duration_seconds"]
        accelerometerOnDurationSeconds  <- map["device_settings.accelerometer_on_duration_seconds"]
        bluetooth                       <- map["device_settings.bluetooth"]
        bluetoothGlobalOffsetSeconds    <- map["device_settings.bluetooth_global_offset_seconds"]
        bluetoothOnDurationSeconds      <- map["device_settings.bluetooth_on_duration_seconds"]
        bluetoothTotalDurationSeconds   <- map["device_settings.bluetooth_total_duration_seconds"]
        callClinicianText               <- map["device_settings.call_clinician_button_text"]
        calls                           <- map["device_settings.calls"]
        checkForNewSurveysFreqSeconds   <- map["device_settings.check_for_new_surveys_frequency_seconds"]
        consentFormText                 <- map["device_settings.consent_form_text"]
        createNewDataFileFrequencySeconds   <- map["device_settings.create_new_data_files_frequency_seconds"]
        gps                             <- map["device_settings.gps"]
        gpsOffDurationSeconds           <- map["device_settings.gps_off_duration_seconds"]
        gpsOnDurationSeconds            <- map["device_settings.gps_on_duration_seconds"]
        powerState                      <- map["device_settings.power_state"]
        secondsBeforeAutoLogout         <- map["device_settings.seconds_before_auto_logout"]
        submitSurveySuccessText         <- map["device_settings.survey_submit_success_toast_text"]
        texts                           <- map["device_settings.texts"]
        uploadDataFileFrequencySeconds  <- map["device_settings.upload_data_files_frequency_seconds"]
        voiceRecordingMaxLengthSeconds  <- map["device_settings.voice_recording_max_time_length_seconds"]
        wifi                            <- map["device_settings.wifi"]
        wifiLogFrequencySeconds         <- map["device_settings.wifi_log_frequency_seconds"]
        proximity                       <- map["device_settings.proximity"];
        magnetometer                    <- map["device_settings.magnetometer"];
        magnetometerOffDurationSeconds  <- map["device_settings.magnetometer_off_duration_seconds"];
        magnetometerOnDurationSeconds  <- map["device_settings.magnetometer_on_duration_seconds"];
        gyro                           <- map["device_settings.gyro"];
        gyroOffDurationSeconds         <- map["device_settings.gyro_off_duration_seconds"];
        gyroOnDurationSeconds          <- map["device_settings.gyro_on_duration_seconds"];
        motion                         <- map["device_settings.devicemotion"];
        motionOffDurationSeconds       <- map["device_settings.devicemotion_off_duration_seconds"];
        motionOnDurationSeconds        <- map["device_settings.devicemotion_on_duration_seconds"];
        reachability                   <- map["device_settings.reachability"];
        consentSections                <- map["device_settings.consent_sections"]
        uploadOverCellular             <- map["device_settings.allow_upload_over_cellular_data"]
    }
    
}
