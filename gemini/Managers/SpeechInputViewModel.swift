import Foundation
import Combine
import SwiftUI

@MainActor
final class SpeechInputViewModel: ObservableObject {
    @Published var uiState: UIState = .idle
    @Published var transcribedText: String = ""

    enum UIState: Equatable {
        case idle
        case recording
        case transcribing
        case readyToSend
        case error(String)
    }

    private let manager = SpeechInputManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() { }

    func toggleRecording() {
        switch uiState {
        case .idle, .readyToSend, .error:
            start()
        case .recording:
            stop()
        case .transcribing:
            cancel()
        }
    }

    func start() {
        transcribedText = ""
        Task { [weak self] in
            guard let self else { return }
            do {
                try await manager.startRecording { [weak self] partial in
                    guard let self else { return }
                    DispatchQueue.main.async {
                        self.transcribedText = partial
                        self.uiState = partial.isEmpty ? .recording : .transcribing // when partial appears, show transcribing pulse
                    }
                }
                DispatchQueue.main.async {
                    self.uiState = .recording
                }
            } catch {
                await MainActor.run {
                    self.uiState = .error(error.localizedDescription)
                }
            }
        }
    }

    func stop() {
        manager.stopRecording()
        if !transcribedText.isEmpty {
            uiState = .readyToSend
        } else {
            uiState = .transcribing
        }
    }

    func cancel() {
        manager.cancel()
        uiState = .idle
        transcribedText = ""
    }

    func consumeTextInto(_ binding: Binding<String>) {
        guard !transcribedText.isEmpty else { return }
        binding.wrappedValue = transcribedText
        uiState = .readyToSend
    }
}
