//
//  VoiceProvider.swift
//  EasyLearn
//
//  Created by alex on 21.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation
import AVFoundation

class VoiceProvider {
    private static let synthesizer = AVSpeechSynthesizer()
    private static let voice = AVSpeechSynthesisVoice(language: "en-GB")
    
    static func sayWord(_ wordText: String){
    
        let utterance = AVSpeechUtterance(string: wordText)
        utterance.voice = voice
        utterance.rate = 0.2

        synthesizer.speak(utterance)
    }
}
