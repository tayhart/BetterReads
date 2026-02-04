//
//  SearchView.swift
//  BetterReads
//
//  SwiftUI search view with native navigation.
//

import SwiftUI

// MARK: - SearchView

struct SearchView: View {
    @Environment(Router.self) private var router
    @StateObject private var viewModel: SearchViewModel

    @State private var searchText: String = ""

    init(provider: BookSearchProvider = GoogleBooksProvider()) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(provider: provider))
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            resultsContent
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarHidden(true)
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
        } else if let error = viewModel.error {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text(error.localizedDescription)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            Spacer()
        } else if viewModel.searchResults.isEmpty {
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
                ForEach(viewModel.searchResults) { result in
                    SearchResultRow(book: result.book)
                        .onTapGesture {
                            router.navigate(to: .bookDetails(result.details))
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
            router.navigate(to: .profile)
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
    @Published var searchResults: [BookSearchResult] = []
    @Published var isLoading: Bool = false
    @Published var error: BookSearchError?

    private let provider: BookSearchProvider

    init(provider: BookSearchProvider = GoogleBooksProvider()) {
        self.provider = provider
    }

    func search(query: String) {
        isLoading = true
        searchResults = []
        error = nil

        Task {
            do {
                let results = try await provider.search(query: query)
                self.searchResults = results
                self.isLoading = false
            } catch let searchError as BookSearchError {
                self.error = searchError
                self.isLoading = false
            } catch {
                self.error = .networkError(error)
                self.isLoading = false
            }
        }
    }

    func getBookDetails(at index: Int) -> BookDetails? {
        guard searchResults.indices.contains(index) else {
            return nil
        }
        return searchResults[index].details
    }
}

#Preview {
    ContentView()
}
