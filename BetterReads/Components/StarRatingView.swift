//
//  StarRatingView.swift
//  BetterReads
//
//  Star rating control supporting 0.25-increment ratings from 1 to 5.
//

import SwiftUI

struct StarRatingView: View {
    let rating: Double
    let onRatingChanged: (Double) -> Void

    @State private var draftRating: Double?

    private let starCount = 5
    private let starSize: CGFloat = 30
    private let spacing: CGFloat = 6

    private var totalWidth: CGFloat {
        starSize * CGFloat(starCount) + spacing * CGFloat(starCount - 1)
    }

    private var displayRating: Double {
        draftRating ?? rating
    }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<starCount, id: \.self) { index in
                StarFillView(fill: fillFraction(for: index), size: starSize)
            }
        }
        .frame(width: totalWidth)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    draftRating = snapped(x: value.location.x)
                }
                .onEnded { value in
                    let newRating = snapped(x: value.location.x)
                    draftRating = nil
                    onRatingChanged(newRating)
                }
        )
    }

    private func snapped(x: CGFloat) -> Double {
        let clamped = max(0, min(x, totalWidth))
        let raw = Double(clamped) / Double(totalWidth) * Double(starCount)
        let snapped = (raw * 4).rounded() / 4
        return min(max(snapped, 1.0), Double(starCount))
    }

    private func fillFraction(for index: Int) -> Double {
        let starFloor = Double(index)
        let starCeil = Double(index + 1)
        if displayRating >= starCeil { return 1.0 }
        if displayRating <= starFloor { return 0.0 }
        return displayRating - starFloor
    }
}

private struct StarFillView: View {
    let fill: Double // 0.0–1.0
    let size: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: size, height: size)
                .foregroundStyle(Color(.systemGray4))

            Image(systemName: "star.fill")
                .resizable()
                .frame(width: size, height: size)
                .foregroundStyle(.yellow)
                .frame(width: size * fill, alignment: .leading)
                .clipped()
        }
        .frame(width: size, height: size)
    }
}
