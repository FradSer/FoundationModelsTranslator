import SwiftUI

enum GlassMaterialKind: Equatable {
    case ultraThin
    case thin
    case regular

    var material: Material {
        switch self {
        case .ultraThin:
            return .ultraThinMaterial
        case .thin:
            return .thinMaterial
        case .regular:
            return .regularMaterial
        }
    }
}

enum GlassSurfaceKind {
    case windowBackground
    case primarySurface
    case inputArea
    case outputAccent
    case listBackdrop
    case toolbarControl
}

struct GlassSurfaceDescriptor {
    let material: GlassMaterialKind
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowOpacity: Double
    let strokeOpacity: Double
}

enum GlassDesign {
    static func descriptor(for kind: GlassSurfaceKind) -> GlassSurfaceDescriptor {
        switch kind {
        case .windowBackground:
            return GlassSurfaceDescriptor(
                material: .ultraThin,
                cornerRadius: 0,
                shadowRadius: 0,
                shadowOpacity: 0,
                strokeOpacity: 0
            )
        case .primarySurface:
            return GlassSurfaceDescriptor(
                material: .thin,
                cornerRadius: 16,
                shadowRadius: 0,
                shadowOpacity: 0,
                strokeOpacity: 0.04
            )
        case .inputArea:
            return GlassSurfaceDescriptor(
                material: .regular,
                cornerRadius: 10,
                shadowRadius: 0,
                shadowOpacity: 0,
                strokeOpacity: 0.08
            )
        case .outputAccent:
            return GlassSurfaceDescriptor(
                material: .ultraThin,
                cornerRadius: 12,
                shadowRadius: 0,
                shadowOpacity: 0,
                strokeOpacity: 0.03
            )
        case .listBackdrop:
            return GlassSurfaceDescriptor(
                material: .ultraThin,
                cornerRadius: 8,
                shadowRadius: 0,
                shadowOpacity: 0,
                strokeOpacity: 0.02
            )
        case .toolbarControl:
            return GlassSurfaceDescriptor(
                material: .thin,
                cornerRadius: 10,
                shadowRadius: 0,
                shadowOpacity: 0,
                strokeOpacity: 0.05
            )
        }
    }
}

extension View {
    func glassSurface(_ kind: GlassSurfaceKind) -> some View {
        let descriptor = GlassDesign.descriptor(for: kind)
        return background(
            RoundedRectangle(cornerRadius: descriptor.cornerRadius, style: .continuous)
                .fill(descriptor.material.material)
                .overlay(
                    RoundedRectangle(cornerRadius: descriptor.cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(descriptor.strokeOpacity), lineWidth: descriptor.strokeOpacity > 0 ? 1 : 0)
                )
                .shadow(
                    color: Color.black.opacity(descriptor.shadowOpacity),
                    radius: descriptor.shadowRadius,
                    x: 0,
                    y: descriptor.shadowRadius > 0 ? descriptor.shadowRadius / 3 : 0
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: descriptor.cornerRadius, style: .continuous))
    }
}
