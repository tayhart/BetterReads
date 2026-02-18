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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let currentBooks = groupedBooks[.currentlyReading], !currentBooks.isEmpty {
                    currentlyReadingSection(currentBooks)
                }

                if let toReadBooks = groupedBooks[.toRead], !toReadBooks.isEmpty {
                    toReadSection(toReadBooks)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await fetchBooks()
        }
    }

    private func currentlyReadingSection(_ books: [UserBook]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                router.navigate(to: .currentlyReading(books))
            } label: {
                HStack {
                    Text(ReadingStatus.currentlyReading.displayTitle)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(books) { book in
                        BookCard(book: book) { newPage in
                            await updateProgress(for: book, to: newPage)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func toReadSection(_ books: [UserBook]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                router.navigate(to: .toRead(books))
            } label: {
                HStack {
                    Text(ReadingStatus.toRead.displayTitle)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(books) { book in
                        BookCard(book: book)
                    }
                }
                .padding(.horizontal)
            }
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

    private func updateProgress(for book: UserBook, to page: Int) async {
        do {
            try await libraryService.updateProgress(bookId: book.bookId, currentPage: page)
            await fetchBooks()
        } catch {
            print("Failed to update progress: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
