//
//  Router.swift
//  BetterReads
//
//  Centralized navigation state management for SwiftUI.
//

import SwiftUI

/// Navigation destinations for the app
enum Route: Hashable {
    case home
    case search
    case bookDetails(BookDetails)
    case profile
    case authentication

    var icon: String {
        switch self {
        case .home:
            return "books.vertical"
        case .search:
            return "magnifyingglass.circle"
        case .profile:
            return "person"
        case .bookDetails, .authentication:
            return ""
        }
    }

    var selectedIcon: String {
        switch self {
        case .home:
            return "books.vertical.fill"
        case .search:
            return "magnifyingglass.circle.fill"
        case .profile:
            return "person.fill"
        case .bookDetails, .authentication:
            return ""
        }
    }
}

/// Centralized router for managing navigation state
@MainActor
@Observable
final class Router {
    var path = NavigationPath()

    func navigate(to route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}

// MARK: - BookDetails Hashable Conformance

extension BookDetails: Hashable {
    static func == (lhs: BookDetails, rhs: BookDetails) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
