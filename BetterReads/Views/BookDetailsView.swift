//
//  BookDetailsView.swift
//  BetterReads
//
//  Unified view for book details. Always uses the full-page layout;
//  tracking sections (progress, dates, rating) appear once the book is saved.
//

import SwiftUI

struct BookDetailsView: View {
    private enum DateField { case started, finished }

    let bookDetails: BookDetails

    @Environment(Router.self) private var router
    @State private var savedBook: UserBook?
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showingSignInPrompt = false
    @State private var isDescriptionExpanded = false
    @State private var showingProgressSheet = false
    @State private var showingDatePicker = false
    @State private var editingDateField: DateField = .started
    @State private var pickerDate = Date()
    @State private var optimisticRating: Double?

    private let authService = AuthService.shared
    private let libraryService = LibraryService.shared

    init(bookDetails: BookDetails, preloadedBook: UserBook? = nil) {
        self.bookDetails = bookDetails
        self._savedBook = State(initialValue: preloadedBook)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                coverSection
                titleSection
                if savedBook != nil { trackingSection }
                statusMenuSection
                if let description = bookDetails.description, !description.isEmpty {
                    descriptionSection(description)
                }
                Spacer()
            }
            .padding(.top)
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if savedBook == nil {
                await fetchSavedBook()
            }
        }
        .alert("Sign In Required", isPresented: $showingSignInPrompt) {
            Button("Sign In") { router.navigate(to: .authentication) }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please sign in to add books to your library.")
        }
        .sheet(isPresented: $showingProgressSheet) {
            if let book = savedBook {
                ProgressUpdateSheet(book: book) { newPage, newPageCount, newMode in
                    if let newPageCount {
                        savedBook = (try? await libraryService.updatePageCount(bookId: book.bookId, pageCount: newPageCount)) ?? savedBook
                    }
                    if let newMode {
                        savedBook = (try? await libraryService.updateProgressMode(bookId: book.bookId, mode: newMode)) ?? savedBook
                    }
                    await updateProgress(to: newPage)
                }
                .presentationDetents([.height(260)])
            }
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

    // MARK: - Layout Sections

    private var coverSection: some View {
        AsyncImage(url: coverURL) { phase in
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
    }

    private var titleSection: some View {
        VStack(spacing: 6) {
            Text(bookDetails.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            if let authors = bookDetails.authors, !authors.isEmpty {
                Text(authors.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let publishYear = bookDetails.publishedDate?.dateYear {
                Text(publishYear)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var trackingSection: some View {
        if let book = savedBook {
            VStack(spacing: 12) {
                // Progress
                if book.pageCount != nil {
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

                            if let pageCount = book.pageCount {
                                Text("Page \(book.currentPage ?? 0) of \(pageCount)")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .foregroundStyle(.foreground)
                    }
                    .padding(.horizontal)
                }

                // Dates
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
                    .padding(.horizontal)
                }

                // Rating
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
                    .padding(.horizontal)
                }
            }
        }
    }

    private var statusMenuSection: some View {
        Menu {
            ForEach(ReadingStatus.allCases, id: \.self) { status in
                Button {
                    if savedBook?.status == status {
                        Task { await removeBook() }
                    } else if savedBook == nil {
                        Task { await saveBook(with: status) }
                    } else {
                        Task { await updateStatus(to: status) }
                    }
                } label: {
                    if savedBook?.status == status {
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
                Text(savedBook?.status.displayTitle ?? "Add to list")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(savedBook != nil ? Color.green : Color.cta)
        .disabled(isSaving)
        .padding(.horizontal)
    }

    private func descriptionSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.headline)
                .padding(.leading, 5)

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isDescriptionExpanded.toggle()
                }
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(description)
                        .font(.body)
                        .lineLimit(isDescriptionExpanded ? nil : 5)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        Spacer()
                        Text(isDescriptionExpanded ? "Show less" : "Show more")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
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

    // MARK: - Computed Properties

    private var coverURL: URL? {
        if let urlString = bookDetails.imageLinks?.bestAvailable {
            return URL(string: urlString)
        }
        if let urlString = savedBook?.coverUrl {
            return URL(string: urlString)
        }
        return nil
    }

    // MARK: - Library Operations

    private func fetchSavedBook() async {
        do {
            savedBook = try await libraryService.fetchBook(bookId: bookDetails.id)
        } catch {
            print("Failed to fetch saved book: \(error)")
        }
    }

    private func saveBook(with status: ReadingStatus) async {
        guard authService.isAuthenticated else {
            showingSignInPrompt = true
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            try await libraryService.saveBook(bookDetails, status: status)
            let fetched = try await libraryService.fetchBook(bookId: bookDetails.id)
            withAnimation { savedBook = fetched }
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to save book: \(error)")
        }
    }

    private func removeBook() async {
        guard let book = savedBook else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            try await libraryService.removeBook(bookId: book.bookId)
            withAnimation { savedBook = nil }
        } catch {
            print("Failed to remove book: \(error)")
        }
    }

    private func updateProgress(to page: Int) async {
        guard let book = savedBook else { return }
        do {
            savedBook = try await libraryService.updateProgress(bookId: book.bookId, currentPage: page)
        } catch {
            print("Failed to update progress: \(error)")
        }
    }

    private func updateRating(to rating: Double) async {
        guard let book = savedBook else { return }
        optimisticRating = rating
        do {
            savedBook = try await libraryService.updateRating(bookId: book.bookId, rating: rating)
            optimisticRating = nil
        } catch {
            optimisticRating = nil
            print("Failed to update rating: \(error)")
        }
    }

    private func updateDate(_ date: Date, field: DateField) async {
        guard let book = savedBook else { return }
        do {
            switch field {
            case .started:
                savedBook = try await libraryService.updateStartDate(bookId: book.bookId, date: date)
            case .finished:
                savedBook = try await libraryService.updateFinishDate(bookId: book.bookId, date: date)
            }
        } catch {
            print("Failed to update date: \(error)")
        }
    }

    private func updateStatus(to status: ReadingStatus) async {
        guard let book = savedBook else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            let previousStatus = book.status
            try await libraryService.updateStatus(bookId: book.bookId, status: status)
            if status == .currentlyReading && book.startedAt == nil {
                savedBook = try await libraryService.updateStartDate(bookId: book.bookId, date: Date())
            } else if status == .read && previousStatus == .currentlyReading {
                if let pageCount = book.pageCount {
                    savedBook = try await libraryService.updateProgress(bookId: book.bookId, currentPage: pageCount)
                }
                savedBook = try await libraryService.updateFinishDate(bookId: book.bookId, date: Date())
            } else {
                await refetchBook()
            }
        } catch {
            print("Failed to update status: \(error)")
        }
    }

    private func refetchBook() async {
        guard let book = savedBook else { return }
        do {
            savedBook = try await libraryService.fetchBook(bookId: book.bookId)
        } catch {
            print("Failed to refetch book: \(error)")
        }
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
        .environment(Router())
    }
}
