import Foundation

extension Bundle {
    /// Provides access to resources bundled with the IELTSDictationCore target.
    #if SWIFT_PACKAGE
    public static let coreModule = Bundle.module
    #endif
}
