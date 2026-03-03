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

    init(provider: BookSearchProvider = SupabaseSearchProvider()) {
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
            skeletonList
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

    private var skeletonList: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(0..<6, id: \.self) { _ in
                    SearchResultSkeletonRow()
                }
            }
            .padding(15)
        }
        .allowsHitTesting(false)
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
        Button {
            router.popToRoot()
        } label: {
            Image(systemName: Route.home.icon)
        }
        .tint(.teal)
        Spacer()
        Button { } label: {
            Image(systemName: Route.search.selectedIcon)
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

    init(provider: BookSearchProvider = SupabaseSearchProvider()) {
        self.provider = provider
    }

    func search(query: String) {
        isLoading = true
        searchResults = []
        error = nil

        Task {
            defer { isLoading = false }
            do {
                let results = try await provider.search(query: query)
                self.searchResults = results
            } catch let searchError as BookSearchError {
                self.error = searchError
            } catch {
                self.error = .networkError(error)
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

// MARK: - Skeleton Row

struct SearchResultSkeletonRow: View {
    @State private var shimmerOffset: CGFloat = -1

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            shimmerRect(width: 100, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 4))

            VStack(alignment: .leading, spacing: 10) {
                shimmerRect(width: 160, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                shimmerRect(width: 110, height: 13)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.15), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 5)
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                shimmerOffset = 1
            }
        }
    }

    private func shimmerRect(width: CGFloat, height: CGFloat) -> some View {
        Rectangle()
            .fill(shimmerGradient)
            .frame(width: width, height: height)
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(UIColor.systemGray5), location: 0),
                .init(color: Color(UIColor.systemGray4), location: 0.4),
                .init(color: Color(UIColor.systemGray5), location: 1),
            ],
            startPoint: UnitPoint(x: shimmerOffset - 0.4, y: 0.5),
            endPoint: UnitPoint(x: shimmerOffset + 0.4, y: 0.5)
        )
    }
}

#Preview {
    ContentView()
}
