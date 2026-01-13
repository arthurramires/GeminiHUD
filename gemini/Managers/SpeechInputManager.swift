import Foundation
import AVFoundation
import Speech

public enum SpeechState: Equatable {
    case idle
    case recording
    case transcribing
    case error(String)
}

public final class SpeechInputManager: NSObject {
    public static let shared = SpeechInputManager()

    private let audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode? { audioEngine.inputNode }
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    @MainActor public private(set) var state: SpeechState = .idle

    private override init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
        super.init()
    }

    // MARK: - Permissions

    public func checkPermissions() async -> (mic: Bool, speech: SFSpeechRecognizerAuthorizationStatus) {
        let micGranted = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .authorized:
                cont.resume(returning: true)
            case .denied, .restricted:
                cont.resume(returning: false)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    cont.resume(returning: granted)
                }
            @unknown default:
                cont.resume(returning: false)
            }
        }

        let speechAuth = await withCheckedContinuation { (cont: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status)
            }
        }
        return (micGranted, speechAuth)
    }

    // MARK: - Recording lifecycle

    @MainActor
    public func startRecording(partialHandler: ((String) -> Void)? = nil) async throws {
        guard state == .idle else { return }

        // Permissions
        let (mic, speech) = await checkPermissions()
        guard mic else {
            state = .error("Permissão de microfone negada")
            throw NSError(domain: "SpeechInput", code: 1, userInfo: [NSLocalizedDescriptionKey: "Microfone não autorizado"]) 
        }
        guard speech == .authorized else {
            state = .error("Permissão de fala negada")
            throw NSError(domain: "SpeechInput", code: 2, userInfo: [NSLocalizedDescriptionKey: "Transcrição não autorizada"]) 
        }
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            state = .error("Reconhecedor indisponível")
            throw NSError(domain: "SpeechInput", code: 3, userInfo: [NSLocalizedDescriptionKey: "Reconhecedor indisponível"]) 
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    partialHandler?(text)
                }
                if result.isFinal {
                    DispatchQueue.main.async {
                        self.stopAudioChain()
                        self.state = .idle
                    }
                }
            }
            if let error = error as NSError?, error.code != 0 {
                DispatchQueue.main.async {
                    self.state = .error(error.localizedDescription)
                    self.stopAudioChain()
                }
            }
        }

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        await MainActor.run {
            self.state = .recording
        }
    }

    @MainActor
    public func stopRecording() {
        guard state == .recording else { return }
        stopAudioChain()
        state = .transcribing // brief state while we await final callback; will flip to idle when final result arrives
    }

    @MainActor
    public func cancel() {
        stopAudioChain()
        state = .idle
    }

    @MainActor
    private func stopAudioChain() {
        if audioEngine.isRunning { audioEngine.stop() }
        inputNode?.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }
}
