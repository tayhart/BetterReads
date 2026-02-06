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
                            BookRow(book: book) { newPage in
                                await updateProgress(for: book, to: newPage)
                            }
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

    private func updateProgress(for book: UserBook, to page: Int) async {
        do {
            try await libraryService.updateProgress(bookId: book.bookId, currentPage: page)
            await fetchBooks()
        } catch {
            print("Failed to update progress: \(error)")
        }
    }
}

// MARK: - Book Row

private struct BookRow: View {
    let book: UserBook
    let onProgressUpdate: ((Int) async -> Void)?

    @State private var showingProgressSheet = false

    init(book: UserBook, onProgressUpdate: ((Int) async -> Void)? = nil) {
        self.book = book
        self.onProgressUpdate = onProgressUpdate
    }

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

                if book.status == .currentlyReading {
                    progressView
                } else if let pageCount = book.pageCount {
                    Text("\(pageCount) pages")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingProgressSheet) {
            ProgressUpdateSheet(book: book, onSave: onProgressUpdate)
                .presentationDetents([.height(200)])
        }
    }

    @ViewBuilder
    private var progressView: some View {
        Button {
            showingProgressSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                ProgressView(value: book.progressPercentage)
                    .tint(.green)

                if let pageCount = book.pageCount {
                    Text("\(book.currentPage ?? 0) of \(pageCount) pages")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Progress Update Sheet

private struct ProgressUpdateSheet: View {
    let book: UserBook
    let onSave: ((Int) async -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: Int
    @State private var isSaving = false

    init(book: UserBook, onSave: ((Int) async -> Void)?) {
        self.book = book
        self.onSave = onSave
        self._currentPage = State(initialValue: book.currentPage ?? 0)
    }

    private var maxPages: Int {
        book.pageCount ?? 1000
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Update Progress")
                    .font(.headline)

                HStack {
                    Text("Page")
                    TextField("Page", value: $currentPage, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                    Text("of \(maxPages)")
                        .foregroundStyle(.secondary)
                }

                Slider(
                    value: Binding(
                        get: { Double(currentPage) },
                        set: { currentPage = Int($0) }
                    ),
                    in: 0...Double(maxPages),
                    step: 1
                )
                .tint(.green)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isSaving = true
                            await onSave?(currentPage)
                            isSaving = false
                            dismiss()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
