import SwiftUI

struct PromptHUDView: View {

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    @StateObject private var speechVM = SpeechInputViewModel()

    let onSubmit: (String) -> Void
    let onDismiss: () -> Void

    private var micButton: some View {
        Button {
            speechVM.toggleRecording()
            if case .idle = speechVM.uiState {
                // no-op
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(speechVM.uiState == .recording ? 0.25 : 0.12))
                    .frame(width: 28, height: 28)
                    .scaleEffect(speechVM.uiState == .recording ? 1.08 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: speechVM.uiState == .recording)

                Image(systemName: iconNameForMic())
                    .font(.system(size: 14, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
            }
        }
        .buttonStyle(.plain)
        .help(helpTextForMic())
        .onChange(of: speechVM.transcribedText) { oldValue, newValue in
            if !newValue.isEmpty {
                text = newValue
            }
        }
    }

    private func iconNameForMic() -> String {
        switch speechVM.uiState {
        case .idle: return "mic"
        case .recording: return "waveform"
        case .transcribing: return "hourglass"
        case .readyToSend: return "checkmark"
        case .error: return "exclamationmark.triangle"
        }
    }

    private func helpTextForMic() -> String {
        switch speechVM.uiState {
        case .idle: return "Start voice input"
        case .recording: return "Stop recording"
        case .transcribing: return "Transcribing…"
        case .readyToSend: return "Ready to send"
        case .error: return "Tap to retry"
        }
    }

    private var statusLine: some View {
        Group {
            switch speechVM.uiState {
            case .recording:
                Text("Gravando… fale agora")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            case .transcribing:
                Text("Transcrevendo…")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            case .readyToSend:
                Text("Texto pronto — revise e envie")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            case .error(let msg):
                Text(msg)
                    .font(.system(size: 11))
                    .foregroundStyle(.red)
            case .idle:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 34)
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 12) {

                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)

                TextField("Pergunte alguma coisa", text: $text)
                    .focused($isFocused)
                    .textFieldStyle(.plain)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .onSubmit {
                        submit()
                    }

                micButton

                Button {
                    submit()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            statusLine
        }
        .padding(.leading, 16)
        .padding(.trailing, 40) // Espaço para o botão fechar
        .padding(.vertical, 12)
        .frame(width: 520)
        .background(
            ZStack {
                VisualEffectView(material: .hudWindow)
                Color.black.opacity(0.3) // Reforça o contraste
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.2), lineWidth: 1) // Borda mais visível
        )
        .overlay(alignment: .trailing) { // Botão Fechar independente
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary.opacity(0.8))
            }
            .buttonStyle(.plain)
            .padding(.trailing, 12)
        }
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10) // Sombra mais forte
        .onAppear {
            text = ""
            // Pequeno delay para garantir que a janela está ativa antes de focar
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isFocused = true
            }
        }
        .onExitCommand {
            onDismiss()
        }
    }

    private func submit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSubmit(trimmed)
        onDismiss()
    }
}

