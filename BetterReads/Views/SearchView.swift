//
//  SearchView.swift
//  BetterReads
//
//  SwiftUI replacement for SearchViewController + SearchResultsCollectionViewController
//

import SwiftUI

// MARK: - SearchView

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText: String = ""

    var onProfileTapped: (() -> Void)?
    var onVolumeTapped: ((GoogleBooksResponse.Volume) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            resultsContent
        }
        .background(Color(UIColor.systemBackground))
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                bottomToolbar
            }
        }
    }

    // MARK: - Subviews

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.primaryAccent)

            TextField("Search for a book or author", text: $searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit { performSearch() }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var resultsContent: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else if $viewModel.books.isEmpty {
            Spacer()
            Text("Search for books to get started")
                .foregroundStyle(.secondary)
            Spacer()
        } else {
            resultsList
        }
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(Array(viewModel.books.enumerated()), id: \.element.id) { index, book in
                    SearchResultRow(book: book)
                        .onTapGesture {
                            if let volume = viewModel.getVolume(at: index) {
                                onVolumeTapped?(volume)
                            }
                        }
                }
            }
            .padding(15)
        }
    }

    @ViewBuilder
    private var bottomToolbar: some View {
        Spacer()
        Button { } label: {
            Image(systemName: "house")
        }
        .tint(.teal)
        Spacer()
        Button { } label: {
            Image(systemName: "magnifyingglass")
        }
        .tint(.mint)
        Spacer()
        Button {
            onProfileTapped?()
        } label: {
            Image(systemName: "person")
        }
        .tint(.pink)
        Spacer()
    }

    private func performSearch() {
        guard !searchText.isEmpty else { return }
        viewModel.search(query: searchText)
    }
}

// MARK: - ViewModel for SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading: Bool = false

    private let dataController = BooksDataController()
    private var response: GoogleBooksResponse?

    func search(query: String) {
        isLoading = true
        books = []

        dataController.request(query) { [weak self] result in
            DispatchQueue.main.async {
                self?.response = result
                self?.books = result.items.compactMap { volume in
                    guard let title = volume.volumeInfo.title,
                          let author = volume.volumeInfo.authors?.first else {
                        return nil
                    }
                    let coverLink = volume.volumeInfo.imageLinks?.thumbnail?.replacingOccurrences(of: "&edge=curl", with: "")
                    return Book(id: volume.id, title: title, author: author, cover: coverLink)
                }
                self?.isLoading = false
            }
        }
    }

    func getVolume(at index: Int) -> GoogleBooksResponse.Volume? {
        guard let response = response,
              response.items.indices.contains(index) else {
            return nil
        }
        return response.items[index]
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
