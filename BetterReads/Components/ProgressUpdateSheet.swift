//
//  ProgressUpdateSheet.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/17/26.
//

import SwiftUI

struct ProgressUpdateSheet: View {
    let book: UserBook
    let onSave: ((Int) async -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: Int
    @State private var isSaving = false

    init(book: UserBook, onSave: ((Int) async -> Void)?) {
        self.book = book
        self.onSave = onSave
        self._currentPage = State(initialValue: book.currentPage ?? 0)
    }

    private var maxPages: Int {
        book.pageCount ?? 1000
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Update Progress")
                    .font(.headline)

                HStack {
                    Text("Page")
                    TextField("Page", value: $currentPage, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                    Text("of \(maxPages)")
                        .foregroundStyle(.secondary)
                }

                Slider(
                    value: Binding(
                        get: { Double(currentPage) },
                        set: { currentPage = Int($0) }
                    ),
                    in: 0...Double(maxPages),
                    step: 1
                )
                .tint(.green)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isSaving = true
                            await onSave?(currentPage)
                            isSaving = false
                            dismiss()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
}
