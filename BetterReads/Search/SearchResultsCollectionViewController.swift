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
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: configuration))
        self.delegate = delegate

        let cellRegistration = UICollectionView.CellRegistration<SearchResultViewCell, Book>
        { cell, indexPath, book in
            cell.configure(with: book)
            cell.accessories = [.disclosureIndicator()]
        }

        DispatchQueue.main.async { [self] in //why is this here?
            self.dataSource = UICollectionViewDiffableDataSource<Section, Book>(collectionView: self.collectionView)
            { (collectionView, indexPath, book) -> UICollectionViewCell? in
                return collectionView.dequeueConfiguredReusableCell(
                    using:cellRegistration,
                    for: indexPath,
                    item: book)
            }
        }

        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
