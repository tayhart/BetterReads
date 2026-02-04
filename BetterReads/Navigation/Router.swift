//
//  Router.swift
//  BetterReads
//
//  Centralized navigation state management for SwiftUI.
//

import SwiftUI

/// Navigation destinations for the app
enum Route: Hashable {
    case search
    case bookDetails(BookDetails)
    case profile
    case authentication
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
