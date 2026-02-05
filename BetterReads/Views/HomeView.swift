//
//  HomeView.swift
//  BetterReads
//
//  Landing screen for the app.
//

import SwiftUI

struct HomeView: View {
    @Environment(Router.self) private var router

    var body: some View {
        VStack {
            Spacer()
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
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                bottomToolbar
            }
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
}

#Preview {
    ContentView()
}
