import AVFoundation
import AppKit

/// Provides text-to-speech pronunciation for English words.
/// Requires AppKit/AVFoundation (macOS only, not part of Core).
public enum WordSpeaker {
    private static let synthesizer: AVSpeechSynthesizer = {
        let synth = AVSpeechSynthesizer()
        return synth
    }()

    private static var englishVoice: AVSpeechSynthesisVoice? = {
        // Prefer a British English voice for IELTS context
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_en-GB_premium") {
            return voice
        }
        if let voice = AVSpeechSynthesisVoice(language: "en-GB") {
            return voice
        }
        return AVSpeechSynthesisVoice(language: "en-US")
    }()

    /// Speak the given English word.
    /// - Parameter word: The word to pronounce.
    public static func speak(_ word: String) {
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = englishVoice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    /// Stop any ongoing speech.
    public static func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    /// Whether the synthesizer is currently speaking.
    public static var isSpeaking: Bool {
        synthesizer.isSpeaking
    }
}
