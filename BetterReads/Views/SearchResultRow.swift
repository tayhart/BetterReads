//
//  SearchResultRow.swift
//  BetterReads
//
//  SwiftUI replacement for SearchResultViewCell
//

import SwiftUI

struct SearchResultRow: View {
    let book: Book

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            AsyncImage(url: URL(string: book.cover ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 150)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 135)
                case .failure:
                    Image(systemName: "book.closed")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray)
                        .frame(width: 100, height: 150)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxHeight: 180)

            VStack(alignment: .leading, spacing: 10) {
                Text(book.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(3)

                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.primary)
        }
        .padding(10)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 5)
    }
}

#Preview {
    SearchResultRow(book: .init(
        id: "",
        title: "The Great Gatsby",
        author: "F. Scott Fitzgerald",
        cover: nil)
    )
    .padding()
}
