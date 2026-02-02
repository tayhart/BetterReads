//
//  VolumeDetailsView.swift
//  BetterReads
//
//  SwiftUI replacement for VolumeDetailsViewController + QuickLookView
//

import SwiftUI

struct VolumeDetailsView: View {
    let volume: GoogleBooksResponse.Volume
    @State private var selectedList: ListType?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Quick Look Section
                quickLookSection

                // Description Section
                descriptionSection
            }
            .padding(.horizontal, 12)
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Quick Look Section

    private var quickLookSection: some View {
        HStack(alignment: .center, spacing: 12) {
            // Book Cover
            AsyncImage(url: coverURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 128, height: 192)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 150)
                case .failure:
                    Image(systemName: "book.closed")
                        .font(.system(size: 50))
                        .foregroundStyle(.gray)
                        .frame(width: 128, height: 192)
                @unknown default:
                    EmptyView()
                }
            }
            .padding(10)

            // Book Info Stack
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(authors)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(publishDate)
                    .font(.callout)

                Text(pageCount)
                    .font(.callout)

                Text(rating)
                    .font(.callout)

                // Add to List Menu
                Menu {
                    ForEach(ListType.allCases, id: \.self) { listType in
                        Button(listType.title) {
                            selectedList = listType
                        }
                    }
                } label: {
                    Text(selectedList?.title ?? "Add to list")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.cta)
            }

            Spacer()
        }
        .padding(.top, 12)
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.headline)
                .padding(.leading, 5)

            Text(descriptionText)
                .font(.body)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary, lineWidth: 1)
                )
        }
    }

    // MARK: - Computed Properties

    private var coverURL: URL? {
        guard let urlString = volume.volumeInfo.imageLinks?.large ??
                volume.volumeInfo.imageLinks?.medium ??
                volume.volumeInfo.imageLinks?.small ??
                volume.volumeInfo.imageLinks?.thumbnail else {
            return nil
        }
        return URL(string: urlString.replacingOccurrences(of: "&edge=curl", with: ""))
    }

    private var title: String {
        volume.volumeInfo.title ?? "Unknown"
    }

    private var authors: String {
        guard let authors = volume.volumeInfo.authors else {
            return "No author found"
        }
        return authors.joined(separator: ", ")
    }

    private var publishDate: String {
        guard let date = volume.volumeInfo.publishedDate else {
            return "Unknown published date"
        }
        return "Published in \(date)"
    }

    private var pageCount: String {
        guard let count = volume.volumeInfo.pageCount else {
            return "Unknown number of pages"
        }
        return "\(count) pages"
    }

    private var rating: String {
        guard let rating = volume.volumeInfo.averageRating else {
            return "Unrated"
        }
        return "\(rating) out of 5"
    }

    private var descriptionText: String {
        volume.volumeInfo.description ?? "No description available"
    }
}

// MARK: - ListType

enum ListType: CaseIterable {
    case toRead, currentlyReading, read, didNotFinish

    var title: String {
        switch self {
        case .toRead:
            return "To read"
        case .currentlyReading:
            return "Currently reading"
        case .read:
            return "Read"
        case .didNotFinish:
            return "Did not finish"
        }
    }
}

#Preview {
    NavigationStack {
        VolumeDetailsView(volume: GoogleBooksResponse.Volume(
            kind: "books#volume",
            id: "test123",
            etag: "etag",
            selfLink: "https://example.com",
            volumeInfo: GoogleBooksResponse.VolumeInfo(
                title: "The Great Gatsby",
                authors: ["F. Scott Fitzgerald"],
                publisher: "Scribner",
                publishedDate: "1925",
                description: "The Great Gatsby is a 1925 novel by American writer F. Scott Fitzgerald. Set in the Jazz Age on Long Island, near New York City, the novel depicts first-person narrator Nick Carraway's interactions with mysterious millionaire Jay Gatsby and Gatsby's obsession to reunite with his former lover, Daisy Buchanan.",
                industryIdentifiers: nil,
                pageCount: 180,
                dimensions: nil,
                printType: "BOOK",
                categories: ["Fiction"],
                mainCategory: nil,
                averageRating: 4.2,
                ratingsCount: 1500,
                contentVersion: "1.0.0",
                imageLinks: nil
            )
        ))
    }
}
