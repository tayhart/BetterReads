//
//  ReadingView.swift
//  BetterReads
//
//  Personalized reading view for currently-reading books.
//

import SwiftUI

struct ReadingView: View {
    private enum DateField { case started, finished }

    @Environment(Router.self) private var router
    @State private var book: UserBook
    @State private var showingProgressSheet = false
    @State private var showingDatePicker = false
    @State private var editingDateField: DateField = .started
    @State private var pickerDate = Date()
    @State private var optimisticRating: Double?
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
                Button {
                    showingProgressSheet = true
                } label: {
                    VStack(spacing: 8) {
                        ProgressView(value: book.progressPercentage)
                            .tint(.green)
                            .scaleEffect(y: 2)

                        Text("\(Int(book.progressPercentage * 100))% complete")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 4) {
                            if let pageCount = book.pageCount {
                                Text("Page \(book.currentPage ?? 0) of \(pageCount)")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .foregroundStyle(.foreground)
                }
                .padding(.horizontal)

                // Dates & Rating
                VStack(spacing: 12) {
                    let showStarted = book.status == .currentlyReading || book.startedAt != nil
                    let showFinished = book.status == .read || book.finishedAt != nil
                    if showStarted || showFinished {
                        VStack(spacing: 0) {
                            if showStarted {
                                dateRow(label: "Started", date: book.startedAt) {
                                    editingDateField = .started
                                    pickerDate = book.startedAt ?? Date()
                                    showingDatePicker = true
                                }
                            }
                            if showStarted && showFinished { Divider().padding(.leading) }
                            if showFinished {
                                dateRow(label: "Finished", date: book.finishedAt) {
                                    editingDateField = .finished
                                    pickerDate = book.finishedAt ?? Date()
                                    showingDatePicker = true
                                }
                            }
                        }
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }

                    if book.status == .read {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Rating")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 12) {
                                StarRatingView(rating: optimisticRating ?? book.rating ?? 0) { newRating in
                                    Task { await updateRating(to: newRating) }
                                }
                                if let rating = optimisticRating ?? book.rating {
                                    Text(rating.formatted(.number.precision(.fractionLength(0...2))))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)

                // Status Menu
                Menu {
                    ForEach(ReadingStatus.allCases, id: \.self) { status in
                        Button {
                            if book.status == status {
                                Task { await removeBook() }
                            } else {
                                Task { await updateStatus(to: status) }
                            }
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
            ProgressUpdateSheet(book: book) { newPage, newPageCount in
                if let newPageCount {
                    book = (try? await libraryService.updatePageCount(bookId: book.bookId, pageCount: newPageCount)) ?? book
                }
                await updateProgress(to: newPage)
            }
            .presentationDetents([.height(200)])
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                DatePicker(
                    editingDateField == .started ? "Start Date" : "Finish Date",
                    selection: $pickerDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .navigationTitle(editingDateField == .started ? "Start Date" : "Finish Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingDatePicker = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let field = editingDateField
                            let date = pickerDate
                            showingDatePicker = false
                            Task { await updateDate(date, field: field) }
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Subviews

    private func dateRow(label: String, date: Date?, onEdit: @escaping () -> Void) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            if let date {
                Button(action: onEdit) {
                    Text(date, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    // MARK: - Actions

    private func updateProgress(to page: Int) async {
        do {
            book = try await libraryService.updateProgress(bookId: book.bookId, currentPage: page)
        } catch {
            print("Failed to update progress: \(error)")
        }
    }

    private func updateRating(to rating: Double) async {
        optimisticRating = rating
        do {
            book = try await libraryService.updateRating(bookId: book.bookId, rating: rating)
            optimisticRating = nil
        } catch {
            optimisticRating = nil
            print("Failed to update rating: \(error)")
        }
    }

    private func removeBook() async {
        isSaving = true
        defer { isSaving = false }

        do {
            try await libraryService.removeBook(bookId: book.bookId)
            router.pop()
            router.navigate(to: .bookDetails(book.toBookDetails()))
        } catch {
            print("Failed to remove book: \(error)")
        }
    }

    private func updateStatus(to status: ReadingStatus) async {
        isSaving = true
        defer { isSaving = false }

        do {
            let previousStatus = book.status
            try await libraryService.updateStatus(bookId: book.bookId, status: status)
            if status == .currentlyReading && book.startedAt == nil {
                book = try await libraryService.updateStartDate(bookId: book.bookId, date: Date())
            } else if status == .read && previousStatus == .currentlyReading {
                if let pageCount = book.pageCount {
                    book = try await libraryService.updateProgress(bookId: book.bookId, currentPage: pageCount)
                }
                book = try await libraryService.updateFinishDate(bookId: book.bookId, date: Date())
            } else {
                await refetchBook()
            }
        } catch {
            print("Failed to update status: \(error)")
        }
    }

    private func updateDate(_ date: Date, field: DateField) async {
        do {
            switch field {
            case .started:
                book = try await libraryService.updateStartDate(bookId: book.bookId, date: date)
            case .finished:
                book = try await libraryService.updateFinishDate(bookId: book.bookId, date: date)
            }
        } catch {
            print("Failed to update date: \(error)")
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
