import Foundation
import Plot

internal struct AtomFeedGenerator<Site: Website> {
    let includedSectionIDs: Set<Site.SectionID>
    let config: AtomFeedConfiguration
    let context: PublishingContext<Site>
    let date: Date

    func generate() throws {
        let outputFile = try context.createOutputFile(at: config.targetPath)
        let cacheFile = try context.cacheFile(named: "feed")
        let oldCache = try? cacheFile.read().decoded() as Cache
        var items = [Item<Site>]()

        for sectionID in includedSectionIDs {
            items += context.sections[sectionID].items
        }

        items.sort { $0.date > $1.date }

        // TODO: reenable caching
//        if let date = context.lastGenerationDate, let cache = oldCache {
//            if cache.config == config, cache.itemCount == items.count {
//                let newlyModifiedItem = items.first { $0.lastModified > date }
//
//                guard newlyModifiedItem != nil else {
//                    return try outputFile.write(cache.feed)
//                }
//            }
//        }

        let feed = makeFeed(containing: items).render(indentedBy: config.indentation)

        let newCache = Cache(config: config, feed: feed, itemCount: items.count)
        try cacheFile.write(newCache.encoded())
        try outputFile.write(feed)
    }
}

private extension AtomFeedGenerator {
    struct Cache: Codable {
        let config: AtomFeedConfiguration
        let feed: String
        let itemCount: Int
    }

    func makeFeed(containing items: [Item<Site>]) -> Atom {
        Atom(
            .id(context.site.url.canonical),
            .title(.text(context.site.name)),
            .subtitle(.text(context.site.description)),
            .author(
                .name(config.author)
            ),
            .link(
                .href(context.site.url.canonical),
                .rel(.alternate)
            ),
            .link(
                .href(
                    context.site.url
                        .appendingPathComponent(config.targetPath.string)
                ),
                .rel(.`self`)
            ),
            .updated(date),
            .forEach(items.prefix(config.maximumItemCount)) { item in
                .entry(
                    .id(
                        context.site.url(for: item).canonical
                    ),
                    .title(.text(item.title)),
                    .summary(.text(item.description)),
                    .link(
                        .href(
                            context.site.url
                            .appendingPathComponent(item.path.string)
                            .canonical
                        ),
                        .rel(.alternate)
                    ),
                    .content(for: item, site: context.site),
                    .published(item.date),
                    .updated(item.lastModified)
                )
            }
        )
    }
}

private extension URLRepresentable {
    var canonical: String {
        if !description.hasSuffix("/") { return description + "/" }
        return description
    }
}

private extension Path {
    var canonical: String {
        if !description.hasSuffix("/") { return description + "/" }
        return description
    }
}
