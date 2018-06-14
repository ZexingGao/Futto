//
//  AudioQuestionViewController.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/25/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import UIKit
import AVFoundation
import PKHUD
import PromiseKit


class AudioQuestionViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    enum AudioState {
        case initial
        case recording
        case recorded
        case playing
    }
    var activeSurvey: ActiveSurvey!
    var maxLen: Int = 60;
    var recordingSession: AVAudioSession!
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var filename: URL?
    var state: AudioState = .initial
    var timer: Timer?
    var currentLength: Double = 0
    var suffix = ".mp4"
    let OUTPUT_CHUNK_SIZE = 128 * 1024

    @IBOutlet weak var maxLengthLabel: UILabel!
    @IBOutlet weak var currentLengthLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var recordPlayButton: UIButton!
    @IBOutlet weak var reRecordButton: BWButton!
    @IBOutlet weak var saveButton: BWButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let prompt = activeSurvey.survey?.questions[0].prompt ?? "";
        /* TESTING
        for _ in 0...100 {
            prompt = prompt + "More text goes here! "
        }
        */
        promptLabel.text = prompt

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action:  #selector(cancelButton))

        reset()

        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                DispatchQueue.main.async {
                    if !allowed {
                        self.fail()
                    }
                }
            }
        } catch {
            fail()
        }
        updateRecordButton()
        recorder = nil

        if let study = StudyManager.sharedInstance.currentStudy {
            // Just need to put any old answer in here...
            activeSurvey.bwAnswers["A"] = "A"
            Recline.shared.save(study).then {_ in
                log.info("Saved.");
                }.catch { e in
                    log.error("Error saving updated answers: \(e)");
            }
        }


    }

    func cleanupAndDismiss() {
        if let filename = filename {
            do {
                try FileManager.default.removeItem(at: filename)
            } catch { }
            self.filename = nil
        }
        recorder?.delegate = nil
        player?.delegate = nil
        recorder?.stop()
        player?.stop()
        player = nil;
        recorder = nil
        StudyManager.sharedInstance.surveysUpdatedEvent.emit(0);
        self.navigationController?.popViewController(animated: true)
    }
    @objc func cancelButton() {
        if (state != .initial) {
            let alertController = UIAlertController(title: "Abandon recording?", message: "", preferredStyle: .actionSheet)

            let leaveAction = UIAlertAction(title: "Abandon", style: .destructive) { (action) in
                DispatchQueue.main.async {
                    self.cleanupAndDismiss()
                }
            }
            alertController.addAction(leaveAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            }
            alertController.addAction(cancelAction)


            self.present(alertController, animated: true) {
            }

        } else {
            cleanupAndDismiss()
        }
    }

    func fail() {
        let alertController = UIAlertController(title: "Recording", message: "Unable to record.  You must allow access to the microphone to answer an audio question", preferredStyle: .alert)

        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            DispatchQueue.main.async {
                self.cleanupAndDismiss()
            }
        }
        alertController.addAction(OKAction)

        self.present(alertController, animated: true) {
        }
    }

    func updateLengthLabel() {
        currentLengthLabel.text = "Length: \(currentLength) seconds"
    }

    @objc func recordingTimer() {
        if let recorder = recorder, recorder.currentTime > 0 {
            currentLength = round(recorder.currentTime * 10) / 10
            if (currentLength >= Double(maxLen)) {
                currentLength = Double(maxLen)
                if (recorder.isRecording) {
                    resetTimer()
                    recorder.stop()
                }
            }

        }
        updateLengthLabel()
    }
    func startRecording() {
        var settings: [String: AnyObject];
        let format = activeSurvey.survey?.audioSurveyType ?? "compressed"
        let bitrate = activeSurvey.survey?.audioBitrate ?? 64000
        let samplerate = activeSurvey.survey?.audioSampleRate ?? 44100

        if (format == "compressed") {
            self.suffix = ".mp4"
            settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC) as AnyObject,
                //AVEncoderBitRateKey: bitrate,
                AVEncoderBitRatePerChannelKey: bitrate as AnyObject,
                AVSampleRateKey: Double(samplerate) as AnyObject,
                AVNumberOfChannelsKey: 1 as NSNumber,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue as AnyObject
            ]
        } else if (format == "raw") {
            self.suffix = ".wav"
            settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM) as AnyObject,
                //AVEncoderBitRateKey: bitrate * 1024,
                AVSampleRateKey: Double(samplerate) as AnyObject,
                AVNumberOfChannelsKey: 1 as NSNumber,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue as AnyObject
            ]
        } else {
            return fail()
        }


        filename = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + suffix)

        do {
            // 5
            log.info("Beginning recording")
            recorder = try AVAudioRecorder(url: filename!, settings: settings)
            recorder?.delegate = self
            currentLength = 0;
            state = .recording
            updateLengthLabel()
            currentLengthLabel.isHidden = false
            recorder?.record()
            resetTimer()
            disableIdleTimer()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(recordingTimer), userInfo: nil, repeats: true)
        } catch  let error as NSError{
            log.error("Err: \(error)")
            fail()
        }
        updateRecordButton()
    }

    func stopRecording() {
        if let recorder = recorder {
            resetTimer()
            recorder.stop()
        }
    }

    func playRecording() {
        if let player = player {
            state = .playing
            player.play()
            updateRecordButton()
        }
    }

    func stopPlaying() {
        if let player = player {
            state = .recorded
            player.stop()
            player.currentTime = 0.0
            updateRecordButton()
        }
    }

    @IBAction func recordCancelPressed(_ sender: AnyObject) {
        switch(state) {
        case .initial:
            startRecording()
        case .recording:
            stopRecording()
        case .recorded:
            playRecording()
        case .playing:
            stopPlaying()
        }
    }

    func writeSomeData(_ handle: FileHandle, encFile: EncryptedStorage) -> Promise<Void> {
        return Promise().then(on: DispatchQueue.global(qos: .background)) {
            let data: Data = handle.readData(ofLength: self.OUTPUT_CHUNK_SIZE)
            if (data.count > 0) {
                return encFile.write(data as NSData, writeLen: data.count).then {
                    return self.writeSomeData(handle, encFile: encFile)
                }
            }
            /* We're done... */
            AppEventManager.sharedInstance.logAppEvent(event: "audio_save_closing", msg: "Closing audio file", d1: encFile.realFilename.lastPathComponent)
            return encFile.close()
        }

    }

    func saveEncryptedAudio() -> Promise<Void> {
        
        if let study = StudyManager.sharedInstance.currentStudy {
            var fileHandle: FileHandle
            do {
                fileHandle = try FileHandle(forReadingFrom: filename!)
            } catch {
                return Promise<Void>(error: BWErrors.ioError)
            }
            let surveyId = self.activeSurvey.survey?.surveyId;
            let name = "voiceRecording" + "_" + surveyId!;
            let encFile = DataStorageManager.sharedInstance.createEncryptedFile(type: name, suffix: suffix)
            return encFile.open().then {
                return self.writeSomeData(fileHandle, encFile: encFile)
            }.always {
                fileHandle.closeFile()
            }
        } else {
            return Promise<Void>(error: BWErrors.ioError)
        }
        /*
        return Promise<Void> { fulfill, reject in
            let is: NSInputStream? = NSInputStream(URL: self.filename)
            if (!)
        }
        */
    }
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        PKHUD.sharedHUD.dimsBackground = true;
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false;

        HUD.show(.labeledProgress(title: "Saving", subtitle: ""))
        AppEventManager.sharedInstance.logAppEvent(event: "audio_save", msg: "Save audio pressed")

         saveEncryptedAudio().then { _ -> Void in
            self.activeSurvey.isComplete = true;
            StudyManager.sharedInstance.cleanupSurvey(self.activeSurvey)
            StudyManager.sharedInstance.updateActiveSurveys(true);
            HUD.flash(.success, delay: 0.5)
            self.cleanupAndDismiss()
        }.catch { err in
            AppEventManager.sharedInstance.logAppEvent(event: "audio_save_fail", msg: "Save audio failed", d1: String(describing: err))
            HUD.flash(.labeledError(title: "Error Saving", subtitle: "Audio answer not sent"), delay: 2.0) { finished in
                self.cleanupAndDismiss()
            }
        }

    }

    func updateRecordButton() {
        /*
        var imageName: String;
        switch(state) {
        case .Initial:
            imageName = "record"
        case .Playing, .Recording:
            imageName = "stop"
        case .Recorded:
            imageName = "play"
        }

        let image = UIImage(named: imageName)
        recordPlayButton.setImage(image, forState: .Highlighted)
        recordPlayButton.setImage(image, forState: .Normal)
        recordPlayButton.setImage(image, forState: .Disabled)
        */
        var text: String
        switch(state) {
        case .initial:
            text = "Record"
        case .playing, .recording:
            text = "Stop"
        case .recorded:
            text = "Play"
        }
        recordPlayButton.setTitle(text, for: .highlighted)
        recordPlayButton.setTitle(text, for: UIControlState())
        recordPlayButton.setTitle(text, for: .disabled)

    }

    func resetTimer() {
        if let timer = timer {
            timer.invalidate();
            self.timer = nil
        }
    }
    func reset() {
        resetTimer()
        filename = nil
        player = nil
        recorder = nil
        state = .initial
        //saveButton.enabled = false
        saveButton.isHidden = true
        reRecordButton.isHidden = true
        maxLen = StudyManager.sharedInstance.currentStudy?.studySettings?.voiceRecordingMaxLengthSeconds ?? 60
        //maxLen = 5
        maxLengthLabel.text = "Maximum length \(maxLen) seconds"
        currentLengthLabel.isHidden = true
        updateRecordButton()
    }
    @IBAction func reRecordButtonPressed(_ sender: AnyObject) {
        recorder?.deleteRecording()
        reset()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func enableIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = false;
    }

    func disableIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = true;
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        log.debug("recording finished, success: \(flag), len: \(currentLength)")
        resetTimer()
        enableIdleTimer();
        if (flag && currentLength > 0.0) {
            self.recorder = nil
            state = .recorded
            //saveButton.enabled = true
            saveButton.isHidden = false
            reRecordButton.isHidden = false
            do {
                player = try AVAudioPlayer(contentsOf: filename!)
                player?.delegate = self
            } catch {
                reset()
            }
            updateRecordButton()
        } else {
            self.recorder?.deleteRecording()
            reset()
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        log.error("Error received in audio recorded: \(error)")
        enableIdleTimer();
        self.recorder?.deleteRecording()
        reset()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (state == .playing) {
            state = .recorded
            updateRecordButton()
        }
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
