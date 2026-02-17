//
//  ReadingView.swift
//  BetterReads
//
//  Personalized reading view for currently-reading books.
//

import SwiftUI

struct ReadingView: View {
    @State private var book: UserBook
    @State private var showingProgressSheet = false
    @State private var isSaving = false

    private let libraryService = LibraryService.shared

    init(book: UserBook) {
        self._book = State(initialValue: book)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Cover
                AsyncImage(url: URL(string: book.coverUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .empty, .failure:
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

                // Title & Author
                VStack(spacing: 6) {
                    Text(book.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    if let authors = book.authors, !authors.isEmpty {
                        Text(authors.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Progress
                VStack(spacing: 8) {
                    ProgressView(value: book.progressPercentage)
                        .tint(.green)
                        .scaleEffect(y: 2)

                    Text("\(Int(book.progressPercentage * 100))% complete")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    if let pageCount = book.pageCount {
                        Text("Page \(book.currentPage ?? 0) of \(pageCount)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal)

                // Update Progress Button
                Button {
                    showingProgressSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text("Update progress")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.green.opacity(0.15))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
                }

                // Status Menu
                Menu {
                    ForEach(ReadingStatus.allCases, id: \.self) { status in
                        Button {
                            Task { await updateStatus(to: status) }
                        } label: {
                            if book.status == status {
                                Label(status.displayTitle, systemImage: "checkmark")
                            } else {
                                Text(status.displayTitle)
                            }
                        }
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(book.status.displayTitle)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(isSaving)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingProgressSheet) {
            ProgressUpdateSheet(book: book) { newPage in
                await updateProgress(to: newPage)
            }
            .presentationDetents([.height(200)])
        }
    }

    // MARK: - Actions

    private func updateProgress(to page: Int) async {
        do {
            try await libraryService.updateProgress(bookId: book.bookId, currentPage: page)
            await refetchBook()
        } catch {
            print("Failed to update progress: \(error)")
        }
    }

    private func updateStatus(to status: ReadingStatus) async {
        isSaving = true
        defer { isSaving = false }

        do {
            try await libraryService.updateStatus(bookId: book.bookId, status: status)
            await refetchBook()
        } catch {
            print("Failed to update status: \(error)")
        }
    }

    private func refetchBook() async {
        do {
            let allBooks = try await libraryService.fetchAllBooks()
            if let updated = allBooks.first(where: { $0.id == book.id }) {
                book = updated
            }
        } catch {
            print("Failed to refetch book: \(error)")
        }
    }
}
