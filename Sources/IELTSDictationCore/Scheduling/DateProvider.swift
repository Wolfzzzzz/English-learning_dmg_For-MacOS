import Foundation

/// Protocol for injecting the current date, enabling deterministic testing.
public protocol DateProvider {
    /// The current date.
    var now: Date { get }
}

/// System implementation that returns the real current date.
public struct SystemDateProvider: DateProvider {
    public var now: Date { Date() }

    public init() {}
}

/// Fixed date provider for testing.
public struct FixedDateProvider: DateProvider {
    public let now: Date

    public init(date: Date) {
        self.now = date
    }
}
