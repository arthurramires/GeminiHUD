import SwiftUI
import AppKit

struct ClipboardOverlayView: View {

    let onDismiss: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 18))
                .foregroundStyle(.primary)

            Text("Clipboard detected — press ⌘V to paste")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Button("Paste") {
                NotificationCenter.default.post(
                    name: .geminiRequestWebViewFocus,
                    object: nil
                )

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    NSApp.sendAction(
                        #selector(NSText.paste(_:)),
                        to: nil,
                        from: nil
                    )
                }

                onDismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            VisualEffectView(material: .hudWindow)
                .clipShape(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
        )
        .shadow(radius: 10)
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .onHover { isHovering = $0 }
    }
}
