//
//  BookDetailsView.swift
//  BetterReads
//
//  SwiftUI view for displaying detailed book information.
//

import SwiftUI

struct BookDetailsView: View {
    let bookDetails: BookDetails

    @State private var currentStatus: ReadingStatus?
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showingSignInPrompt = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                quickLookSection
                descriptionSection
            }
            .padding(.horizontal, 12)
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle(bookDetails.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Quick Look Section

    private var quickLookSection: some View {
        HStack(alignment: .center, spacing: 12) {
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

            VStack(alignment: .leading, spacing: 10) {

                Text(authors)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(publishDate)
                    .font(.callout)

                Text(pageCount)
                    .font(.callout)

                if let rating {
                    Text(rating)
                        .font(.callout)
                }
//
//                Menu {
//                    ForEach(ReadingStatus.allCases, id: \.self) { listType in
//                        Button(listType.title) {
//                        }
//                    }
//                } label: {
//                    Text("Add to list")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//                .buttonStyle(.borderedProminent)
//                .tint(Color.cta)
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
        guard let urlString = bookDetails.imageLinks?.bestAvailable else {
            return nil
        }
        return URL(string: urlString)
    }

    private var authors: String {
        guard let authors = bookDetails.authors, !authors.isEmpty else {
            return "No author found"
        }
        return authors.joined(separator: ", ")
    }

    private var publishDate: String {
        guard let date = bookDetails.publishedDate?.dateYear else {
            return "Unknown published date"
        }
        return "Published in \(date)"
    }

    private var pageCount: String {
        guard let count = bookDetails.pageCount else {
            return "Unknown number of pages"
        }
        return "\(count) pages"
    }

    private var rating: String? {
        guard let rating = bookDetails.averageRating else {
            return nil
        }
        return "\(rating) out of 5"
    }

    private var descriptionText: String {
        bookDetails.description ?? "No description available"
    }
}

#Preview {
    NavigationStack {
        BookDetailsView(bookDetails: BookDetails(
            id: "test123",
            title: "The Great Gatsby",
            authors: ["F. Scott Fitzgerald"],
            publisher: "Scribner",
            publishedDate: "1925",
            description: "The Great Gatsby is a 1925 novel by American writer F. Scott Fitzgerald. Set in the Jazz Age on Long Island, near New York City, the novel depicts first-person narrator Nick Carraway's interactions with mysterious millionaire Jay Gatsby and Gatsby's obsession to reunite with his former lover, Daisy Buchanan.",
            pageCount: 180,
            averageRating: 4.2,
            ratingsCount: 1500,
            categories: ["Fiction"],
            imageLinks: nil,
            isbn10: nil,
            isbn13: nil,
            provider: .googleBooks
        ))
    }
}
