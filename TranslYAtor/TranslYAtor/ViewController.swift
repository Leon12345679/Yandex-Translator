//
//  ViewController.swift
//  TranslYAtor
//
//  Created by Leon Vladimirov on 1/19/19.
//  Copyright © 2019 Leon Vladimirov. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, UITextFieldDelegate, SFSpeechRecognizerDelegate {

    let audioEngine = AVAudioEngine()
    var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "ru"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    var speechText = ""
    var isRecordingButton = true
    
    
    override func viewDidLoad() {
        requestSpeechAuthorization()
        textField.delegate = self
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    @IBOutlet weak var animationContainer: UIView!
    func textFieldDidBeginEditing(_ textField: UITextField) { // became first responder
        
        if isRecording {
            cancelRecording()
        }
        //move textfields up
        self.Send.setImage(UIImage(named: "Mike"), for: .normal)
        let myScreenRect: CGRect = UIScreen.main.bounds
        let keyboardHeight : CGFloat = 216
        
        UIView.beginAnimations( "animateView", context: nil)
        var needToMove: CGFloat = 0
        
        var frame : CGRect = self.view.frame
        if (InputView.frame.origin.y + InputView.frame.size.height + UIApplication.shared.statusBarFrame.size.height > (myScreenRect.size.height - keyboardHeight - 30)) {
            needToMove = (InputView.frame.origin.y + InputView.frame.size.height + UIApplication.shared.statusBarFrame.size.height) - (myScreenRect.size.height - keyboardHeight - 30)
        }
        
        frame.origin.y = -needToMove
        self.view.frame = frame
        UIView.commitAnimations()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.textField.text!.count != 0 {
            self.isRecordingButton = false
            self.Send.setImage(UIImage(named: "Next"), for: .normal)
     
        }
        //move textfields back down
        UIView.beginAnimations( "animateView", context: nil)
        var frame : CGRect = self.view.frame
        frame.origin.y = 0
        self.view.frame = frame
        UIView.commitAnimations()
    }

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var InputView: InputView!
    @IBOutlet weak var Send: UIButton!
    @IBOutlet weak var ChangeLangButton: UIButton!
    
    func SwitchFlag() {
        if ChangeLangButton.currentImage == UIImage(named: "FlagUS") {
            ChangeLangButton.setImage(UIImage(named: "FlagRU"), for: .normal)
            toLang = "ru"
            speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
        } else {
            ChangeLangButton.setImage(UIImage(named: "FlagUS"), for: .normal)
            toLang = "en"
            speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ru"))
        }
    }
    var toLang: String = "en"
    @IBAction func ChangeLang(_ sender: UIButton) {
        InputView.switchColor()
        SwitchFlag()
        
    }

    private let networking = NetworkingMethods()
    private let animation = SpeechAnimation()
    

    
    func cancelRecording() {
        isRecording = false
        // nuke animations
        animationContainer.layer.removeAllAnimations()
        self.animationContainer.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        audioEngine.stop()
        recognitionTask?.cancel()
        
        let node = audioEngine.inputNode
        node.removeTap(onBus: 0)
        }
   
    @IBAction func Translate(_ sender: UIButton) {

        if isRecordingButton {
            if isRecording == true {
                cancelRecording()
                if self.textField.text!.count != 0 {
                    self.isRecordingButton = false
                    self.Send.setImage(UIImage(named: "Next"), for: .normal)
                    
                } else {
                    self.Send.setImage(UIImage(named: "Mike"), for: .normal)
                }
                
               
            } else {
                isRecording = true
                self.animation.setUpAnimation(layer: self.animationContainer.layer, size: self.Send.frame.size, color: UIColor.white)
                self.Send.setImage(nil, for: .normal)
                self.recordAndRecognizeSpeech()
            }
        } else {
            
            let textToTranslate = textField.text!
            if textToTranslate.count != 0 {
                let dic = ["myData": textToTranslate, "request": "1"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Request"), object: nil, userInfo: dic)
            
                networking.Translate(phrase: textToTranslate, toLang: toLang){
                    (String) in
                    // Getting the response from the completion handler into main thread
                    DispatchQueue.main.async {
                        let translatedText = String
                        let dic = ["myData": translatedText, "request": "0"]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Answer"), object: nil, userInfo: dic)
                    }
                }

            textField.text = ""
            self.Send.setImage(UIImage(named: "Mike"), for: .normal)
            isRecordingButton = true
            } 
        }
    }
    
    
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
                self.textField.text = bestString
             
                
            } else if let error = error {
                print(error)
            }
        })
    }
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.Send.isEnabled = true
                case .denied:
                    self.Send.isEnabled = false
                    self.textField.text = "User denied access to speech recognition"
                case .restricted:
                    self.Send.isEnabled = false
                    self.textField.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.Send.isEnabled = false
                    self.textField.text = "Speech recognition not yet authorized"
                }
            }
        }
    }
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

