import XCTest
@testable import FoundationModelsTranslator

final class GlassDesignTests: XCTestCase {
    func testPrimarySurfaceDescriptorPrefersRegularMaterialAndWideRadius() {
        let descriptor = GlassDesign.descriptor(for: .primarySurface)

        XCTAssertEqual(descriptor.material, .thin)
        XCTAssertEqual(descriptor.cornerRadius, 16)
        XCTAssertEqual(descriptor.shadowRadius, 0)
        XCTAssertEqual(descriptor.shadowOpacity, 0, accuracy: 0.001)
        XCTAssertEqual(descriptor.strokeOpacity, 0.04, accuracy: 0.001)
    }

    func testOutputSurfaceDescriptorUsesThinMaterialAndTighterShadow() {
        let descriptor = GlassDesign.descriptor(for: .outputAccent)

        XCTAssertEqual(descriptor.material, .ultraThin)
        XCTAssertEqual(descriptor.cornerRadius, 12)
        XCTAssertEqual(descriptor.shadowRadius, 0)
        XCTAssertEqual(descriptor.shadowOpacity, 0, accuracy: 0.001)
        XCTAssertEqual(descriptor.strokeOpacity, 0.03, accuracy: 0.001)
    }

    func testListBackdropDescriptorAppliesUltraThinMaterialWithoutShadow() {
        let descriptor = GlassDesign.descriptor(for: .listBackdrop)

        XCTAssertEqual(descriptor.material, .ultraThin)
        XCTAssertEqual(descriptor.cornerRadius, 8)
        XCTAssertEqual(descriptor.shadowRadius, 0)
        XCTAssertEqual(descriptor.shadowOpacity, 0, accuracy: 0.001)
        XCTAssertEqual(descriptor.strokeOpacity, 0.02, accuracy: 0.001)
    }
}
