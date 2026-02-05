//
//  HomeView.swift
//  BetterReads
//
//  Landing screen for the app.
//

import SwiftUI

struct HomeView: View {
    @Environment(Router.self) private var router

    @State private var books: [UserBook] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let libraryService = LibraryService.shared

    private var groupedBooks: [ReadingStatus: [UserBook]] {
        Dictionary(grouping: books, by: { $0.status })
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if books.isEmpty {
                emptyState
            } else {
                libraryList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                bottomToolbar
            }
        }
        .task(id: router.path.count) {
            await fetchBooks()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Add to your library to get started")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var libraryList: some View {
        List {
            ForEach(ReadingStatus.allCases, id: \.self) { status in
                if let statusBooks = groupedBooks[status], !statusBooks.isEmpty {
                    Section(status.displayTitle) {
                        ForEach(statusBooks) { book in
                            BookRow(book: book)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await fetchBooks()
        }
    }

    @ViewBuilder
    private var bottomToolbar: some View {
        Spacer()
        Button { } label: {
            Image(systemName: Route.home.selectedIcon)
        }
        .tint(.teal)
        Spacer()
        Button {
            router.navigate(to: .search)
        } label: {
            Image(systemName: Route.search.icon)
        }
        .tint(.mint)
        Spacer()
        Button {
            router.navigate(to: .profile)
        } label: {
            Image(systemName: Route.profile.icon)
        }
        .tint(.pink)
        Spacer()
    }

    // MARK: - Data Fetching

    private func fetchBooks() async {
        isLoading = true
        defer { isLoading = false }

        do {
            books = try await libraryService.fetchAllBooks()
        } catch LibraryError.notAuthenticated {
            books = []
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to fetch books: \(error)")
        }
    }
}

// MARK: - Book Row

private struct BookRow: View {
    let book: UserBook

    var body: some View {
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

                if let pageCount = book.pageCount {
                    Text("\(pageCount) pages")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
