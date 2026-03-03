//
//  ProgressUpdateSheet.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/17/26.
//

import SwiftUI

struct ProgressUpdateSheet: View {
    let book: UserBook
    let onSave: ((Int, Int?) async -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: Int
    @State private var pageCount: Int?
    @State private var isSaving = false

    init(book: UserBook, onSave: ((Int, Int?) async -> Void)?) {
        self.book = book
        self.onSave = onSave
        self._currentPage = State(initialValue: book.currentPage ?? 0)
        self._pageCount = State(initialValue: book.pageCount)
    }

    private var maxPages: Int {
        pageCount ?? book.pageCount ?? 1000
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
                    Text("of")
                        .foregroundStyle(.secondary)
                    TextField("Total", value: $pageCount, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
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
                            let updatedPageCount = pageCount != book.pageCount ? pageCount : nil
                            await onSave?(currentPage, updatedPageCount)
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
