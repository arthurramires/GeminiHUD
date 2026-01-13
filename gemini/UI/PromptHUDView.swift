import SwiftUI

struct PromptHUDView: View {

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    @StateObject private var speechVM = SpeechInputViewModel()
    @State private var gradientPhase: CGFloat = 0

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
                    .fill(Color.accentColor.opacity(0.16))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle().strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .scaleEffect(1.0)

                Image(systemName: iconNameForMic())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.primary)
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
        case .idle: return "mic.fill"
        case .recording: return "stop.fill"
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
        .frame(height: 14, alignment: .leading)
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
        .padding(.vertical, 10)
        .frame(width: 520)
        .background(
            VisualEffectView(material: .hudWindow)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.94, green: 0.28, blue: 0.61),
                            Color(red: 0.43, green: 0.71, blue: 0.98),
                            Color(red: 0.74, green: 0.67, blue: 0.99),
                            Color(red: 1.00, green: 0.72, blue: 0.39),
                            Color(red: 0.94, green: 0.28, blue: 0.61)
                        ]),
                        center: .center,
                        angle: .degrees(Double(gradientPhase))
                    ).opacity(speechVM.uiState == .recording ? 0.95 : 0.30),
                    lineWidth: 1.0
                )
                .blendMode(.plusLighter)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: [Color.white.opacity(0.18), Color.white.opacity(0.06)], startPoint: .top, endPoint: .bottom),
                    lineWidth: 0.5
                )
        )
        .overlay(
            Group {
                if case .recording = speechVM.uiState {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(
                            RadialGradient(colors: [
                                Color.white.opacity(0.16),
                                Color.white.opacity(0.00)
                            ], center: .center, startRadius: 0, endRadius: 220),
                            lineWidth: 1.0
                        )
                        .blendMode(.screen)
                        .opacity(0.7)
                }
            }
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
        .shadow(color: Color.black.opacity(0.25), radius: 14, x: 0, y: 8)
        .onAppear {
            text = ""
            // Pequeno delay para garantir que a janela está ativa antes de focar
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isFocused = true
            }
        }
        .onChange(of: speechVM.uiState) { _, newState in
            if case .recording = newState {
                gradientPhase = 0
                withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
                    gradientPhase = 360
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    gradientPhase = 0
                }
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
