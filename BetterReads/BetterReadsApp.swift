//
//  BetterReadsApp.swift
//  BetterReads
//
//  SwiftUI App lifecycle entry point.
//

import SwiftUI

@main
struct BetterReadsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
