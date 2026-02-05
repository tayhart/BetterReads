//
//  ContentView.swift
//  BetterReads
//
//  Root view with NavigationStack for SwiftUI-native navigation.
//

import SwiftUI

struct ContentView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    destinationView(for: route)
                }
        }
        .environment(router)
    }

    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .home:
            HomeView()
        case .search:
            SearchView()
        case .bookDetails(let details):
            BookDetailsView(bookDetails: details)
        case .profile:
            ProfileView()
        case .authentication:
            AuthenticationView()
        }
    }
}

#Preview {
    ContentView()
}
