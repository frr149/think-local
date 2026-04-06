import SwiftUI
import ImagePlayground
import AppKit

// MARK: - ImageCardView

struct ImageCardView: View {
    let generated: ImageGenerationService.GeneratedImage?
    let style: ImagePlaygroundStyle
    let isGenerating: Bool
    let elapsedTime: TimeInterval

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 3)

                if isGenerating {
                    generatingPlaceholder
                } else if let generated {
                    generatedContent(generated)
                } else {
                    emptyPlaceholder
                }
            }
            .frame(minHeight: 240)
            .onHover { isHovered = $0 }

            styleLabel
        }
    }

    // MARK: - Subviews

    private var generatingPlaceholder: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(.amberGold)

            Text(String(format: "%.1fs", elapsedTime))
                .metricValueStyle()
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func generatedContent(_ g: ImageGenerationService.GeneratedImage) -> some View {
        ZStack(alignment: .bottom) {
            Image(g.image, scale: 1, label: Text(g.prompt))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            if isHovered {
                hoverOverlay(g)
                    .transition(.opacity.animation(.easeInOut(duration: 0.15)))
            }
        }
    }

    private func hoverOverlay(_ g: ImageGenerationService.GeneratedImage) -> some View {
        HStack(spacing: 12) {
            Button {
                saveImage(g)
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
                    .font(.caption.weight(.medium))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))

            Button {
                copyImage(g)
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
                    .font(.caption.weight(.medium))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(.bottom, 12)
    }

    private var emptyPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)
            Text("Waiting")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var styleLabel: some View {
        HStack {
            Text(style.displayName)
                .roleLabelStyle()

            if let g = generated, !isGenerating {
                Spacer()
                Text(String(format: "%.1fs", g.generationTime))
                    .metricValueStyle()
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Actions

    private func saveImage(_ g: ImageGenerationService.GeneratedImage) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "image-\(style.displayName.lowercased()).png"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        writePNG(cgImage: g.image, to: url)
    }

    private func copyImage(_ g: ImageGenerationService.GeneratedImage) {
        let nsImage = NSImage(cgImage: g.image, size: .zero)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([nsImage])
    }

    private func writePNG(cgImage: CGImage, to url: URL) {
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else { return }
        CGImageDestinationAddImage(dest, cgImage, nil)
        CGImageDestinationFinalize(dest)
    }
}

// MARK: - ImagePlaygroundStyle + helpers

extension ImagePlaygroundStyle {
    // Ordered list of styles shown as columns
    static var studioStyles: [ImagePlaygroundStyle] {
        [.animation, .illustration, .sketch]
    }

    var displayName: String {
        if self == .animation { return "Animation" }
        if self == .illustration { return "Illustration" }
        if self == .sketch { return "Sketch" }
        return "Unknown"
    }
}
