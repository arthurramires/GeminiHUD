import SwiftUI

struct PromptHUDView: View {

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    let onSubmit: (String) -> Void
    let onDismiss: () -> Void

    var body: some View {
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

            Button {
                submit()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
