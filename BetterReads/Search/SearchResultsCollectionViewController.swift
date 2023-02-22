//
//  SearchResultsViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 3/24/22.
//

import UIKit

protocol SearchResultsDelegate: AnyObject {
    func openVolumeDetails(for volume: GoogleBooksResponse.Volume)
}

class SearchResultsCollectionViewController: UICollectionViewController {
    private enum Section: CaseIterable {
        case main
    }

    var viewModel: SearchResultViewModel = SearchResultViewModel()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Book>?
    weak var delegate: SearchResultsDelegate?

    init(delegate: SearchResultsDelegate?) {
        super.init(collectionViewLayout: SearchResultsCollectionViewController.layout())
        self.delegate = delegate
        collectionView.backgroundColor = .clear

        let cellRegistration = UICollectionView.CellRegistration<SearchResultViewCell, Book>
        { cell, indexPath, book in
            cell.configure(with: book)
        }

        self.dataSource = UICollectionViewDiffableDataSource<Section, Book>(collectionView: self.collectionView)
        { (collectionView, indexPath, book) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: book)
        }

        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(225))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applySnapshot(animatingDifferences: false)
    }

    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Book>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(viewModel.quickLookData)
        dataSource?.apply(snapshot)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let volume = viewModel.getVolumeDataForIndex(indexPath) else {
            // TODO: Error messaging
            return
        }
        delegate?.openVolumeDetails(for: volume)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
