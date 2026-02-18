//
//  BookCard.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/17/26.
//

import SwiftUI

struct BookCard: View {
    let book: UserBook
    let onProgressUpdate: ((Int) async -> Void)?

    @Environment(Router.self) private var router
    @State private var showingProgressSheet = false

    init(book: UserBook, onProgressUpdate: ((Int) async -> Void)? = nil) {
        self.book = book
        self.onProgressUpdate = onProgressUpdate
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
                .frame(width: 60, height: 90)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))

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

                    Spacer(minLength: 0)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                router.navigate(to: .reading(book))
            }

            ProgressView(value: book.progressPercentage)
                .tint(.green)

            if let pageCount = book.pageCount {
                Button {
                    showingProgressSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text("\(book.currentPage ?? 0) of \(pageCount) pages")
                            .font(.caption2)
                            .fontWeight(.medium)
                        Image(systemName: "pencil")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.15))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
                }
            }
        }
        .padding()
        .frame(width: 220)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .border(.black, width: 1.5)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
        .sheet(isPresented: $showingProgressSheet) {
            ProgressUpdateSheet(book: book, onSave: onProgressUpdate)
                .presentationDetents([.height(200)])
        }
    }
}
