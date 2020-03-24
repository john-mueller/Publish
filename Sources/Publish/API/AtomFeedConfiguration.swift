import Foundation
import Plot

/// Configuration type used to customize how an Atom feed is generated
/// when using the `generateAtomFeed` step. To use a default implementation,
/// use `AtomFeedConfiguration.default`.
public struct AtomFeedConfiguration: FeedConfiguration {
    public var targetPath: Path
    public let ttlInterval: TimeInterval = 0
    public var author: String
    public var maximumItemCount: Int
    public var indentation: Indentation.Kind?

    /// Initialize a new configuration instance.
    /// - Parameter targetPath: The path that the feed should be generated at.
    /// - Parameter author: The feed's author.
    /// - Parameter maximumItemCount: The maximum number of items that the
    ///   feed should contain.
    /// - Parameter indentation: How the feed should be indented.
    public init(
        targetPath: Path = .defaultForAtomFeed,
        author: String = "",
        maximumItemCount: Int = 100,
        indentation: Indentation.Kind? = nil
    ) {
        self.targetPath = targetPath
        self.author = author
        self.maximumItemCount = maximumItemCount
        self.indentation = indentation
    }
}

public extension AtomFeedConfiguration {
    /// Create a default Atom feed configuration implementation.
    static var `default`: AtomFeedConfiguration { .init() }
}
