//
//  BookListView.swift
//  BetterReads
//
//  Shared vertical list view for all reading statuses.
//

import SwiftUI

struct BookListView: View {
    @Environment(Router.self) private var router

    let books: [UserBook]
    let status: ReadingStatus

    private var sortedBooks: [UserBook] {
        guard status == .read else { return books }
        return books.sorted { ($0.finishedAt ?? .distantPast) > ($1.finishedAt ?? .distantPast) }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(sortedBooks) { book in
                    Button {
                        router.navigate(to: .reading(book))
                    } label: {
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: book.coverUrl ?? "")) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .empty, .failure:
                                    Image(systemName: "book.closed")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 50, height: 75)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(book.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(2)

                                if let authors = book.authors, !authors.isEmpty {
                                    Text(authors.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }

                                statusDetail(for: book)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .padding(.leading, 78)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(status.displayTitle)
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func statusDetail(for book: UserBook) -> some View {
        switch status {
        case .currentlyReading:
            VStack(alignment: .leading, spacing: 6) {
                ProgressView(value: book.progressPercentage)
                    .tint(.green)
                if let pageCount = book.pageCount {
                    Text("\(book.currentPage ?? 0) of \(pageCount) pages")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        case .toRead:
            if let pageCount = book.pageCount {
                Text("\(pageCount) pages")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        case .read:
            VStack(alignment: .leading, spacing: 2) {
                if let finishedAt = book.finishedAt {
                    Text("Finished \(finishedAt, style: .date)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if let rating = book.rating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text(rating.formatted(.number.precision(.fractionLength(0...2))))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
            }
        case .didNotFinish:
            EmptyView()
        }
    }
}
