//
//  ProgressUpdateSheet.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/17/26.
//

import SwiftUI

struct ProgressUpdateSheet: View {
    let book: UserBook
    let onSave: ((Int, Int?, ProgressTrackingMode?) async -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: Int
    @State private var pageCount: Int?
    @State private var trackingMode: ProgressTrackingMode
    @State private var percentage: Double
    @State private var isSaving = false

    init(book: UserBook, onSave: ((Int, Int?, ProgressTrackingMode?) async -> Void)?) {
        self.book = book
        self.onSave = onSave
        self._currentPage = State(initialValue: book.currentPage ?? 0)
        self._pageCount = State(initialValue: book.pageCount)
        self._trackingMode = State(initialValue: book.progressMode ?? .page)
        self._percentage = State(initialValue: book.progressPercentage * 100)
    }

    private var maxPages: Int {
        pageCount ?? book.pageCount ?? 1000
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Update Progress")
                    .font(.headline)

                Picker("Mode", selection: $trackingMode) {
                    Text("By Page").tag(ProgressTrackingMode.page)
                    Text("By %").tag(ProgressTrackingMode.percentage)
                }
                .pickerStyle(.segmented)
                .onChange(of: trackingMode) { _, newMode in
                    let pages = Double(maxPages)
                    guard pages > 0 else { return }
                    if newMode == .percentage {
                        percentage = Double(currentPage) / pages * 100
                    } else {
                        currentPage = Int(percentage / 100 * pages)
                    }
                }

                if trackingMode == .page {
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
                } else {
                    HStack {
                        Text("Percent")
                        TextField("0–100", value: $percentage, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                        Text("%")
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $percentage, in: 0...100, step: 1)
                        .tint(.green)
                }

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
                            // Sync currentPage from percentage before saving
                            if trackingMode == .percentage {
                                currentPage = Int(percentage / 100 * Double(maxPages))
                            }
                            let updatedPageCount = pageCount != book.pageCount ? pageCount : nil
                            let changedMode = trackingMode != (book.progressMode ?? .page) ? trackingMode : nil
                            await onSave?(currentPage, updatedPageCount, changedMode)
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
