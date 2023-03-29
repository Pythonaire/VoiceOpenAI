//
//  SpeechAndText.swift
//  VoiceOpenAI
//
//

import SwiftUI
import AVFoundation
import Speech
import NaturalLanguage

struct VoiceAndAnswer: Identifiable {
    let id = UUID()
    let question: String
    var answer: String
}
class SpeechAndText: NSObject, SFSpeechRecognizerDelegate, ObservableObject {
    @Published var searchVoice: String = ""
    @Published var isFinal: Bool = false
    
    let audioEngine = AVAudioEngine()
    let synthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    
    
    func startTranscription() throws {
        self.searchVoice = ""
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        let inputNode = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            guard self.recognitionTask != nil else { return }
            if let result = result, !result.isFinal {
                // Update the text view with the results.
                self.searchVoice = result.bestTranscription.formattedString
                self.isFinal = result.isFinal
                //print("Text \(result.bestTranscription.formattedString)")
            }
            if error != nil || self.isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest?.endAudio()
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        // Configure the microphone input
        // Get the native audio format of the engine's input bus.
        //let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
    }

    func stopTranscription() throws {
        DispatchQueue.main.async {
            self.recognitionTask?.cancel()
            self.recognitionRequest = nil
                    }
        self.recognitionTask = nil
        audioEngine.stop()
        recognitionRequest?.endAudio()
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        self.isFinal = true
        }
    
    func startUtterance(txtAnswer: String) {
        let languageRecognizer = NLLanguageRecognizer()
        languageRecognizer.processString(txtAnswer)
        let language  = languageRecognizer.dominantLanguage!.rawValue
        let speechUtterance = AVSpeechUtterance(string: txtAnswer)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: language)
        speechUtterance.rate = 0.50
        speechUtterance.pitchMultiplier = 0.8
        speechUtterance.postUtteranceDelay = 0.2
        speechUtterance.volume = 1.0
        synthesizer.speak(speechUtterance)
        languageRecognizer.reset()
    }
    
    func stopUtterance() {
        synthesizer.stopSpeaking(at: .immediate)
    }
   
}
