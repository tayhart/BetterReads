//
//  CurrentlyReadingView.swift
//  BetterReads
//
//  Vertical list of all currently reading books.
//

import SwiftUI

struct CurrentlyReadingView: View {
    @Environment(Router.self) private var router

    let books: [UserBook]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(books) { book in
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

                                VStack(alignment: .leading, spacing: 6) {
                                    ProgressView(value: book.progressPercentage)
                                        .tint(.green)

                                    if let pageCount = book.pageCount {
                                        Text("\(book.currentPage ?? 0) of \(pageCount) pages")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
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
        .navigationTitle(ReadingStatus.currentlyReading.displayTitle)
        .navigationBarTitleDisplayMode(.large)
    }
}
