//
//  SearchResultsViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 3/24/22.
//

import UIKit

protocol SearchResultsDelegate: AnyObject {
    func didSelectItem(_ book: Book)
}

struct Book: Hashable {
    var title: String
    var author: String
    var cover: UIImage
}

class SearchResultsCollectionViewController: UICollectionViewController {
    private enum Section: CaseIterable {
        case main
    }

    var data: GoogleBooksResponse?
    var books = [Book]() {
        didSet {
            applySnapshot()
        }
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, Book>?
    weak var delegate: SearchResultsDelegate?

    init(delegate: SearchResultsDelegate?) {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: configuration))
        self.delegate = delegate

        //TODO: move this out of here
        let cellRegistration = UICollectionView.CellRegistration<SearchResultViewCell, Book>
        { cell, indexPath, book in
            cell.configure(
                cover: book.cover,
                author: book.author,
                title: book.title)
            cell.accessories = [.disclosureIndicator()]
        }

        DispatchQueue.main.async { [self] in //why is this here
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

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Book>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(books)
        dataSource?.apply(snapshot)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard books.indices.contains(indexPath.row) else {
            //TODO: Something went wrong messaging
            return
        }
        delegate?.didSelectItem(books[indexPath.row])
    }

    func populateWithData(responseData: GoogleBooksResponse) { //move to a data controller
        data = responseData
        guard let data = data else { return }

        books = data.items.compactMap({ volume in
            guard let title = volume.volumeInfo.title,
                  let author = volume.volumeInfo.authors?[0] else {
                      return nil
                  }


            if let coverURL =  volume.volumeInfo.imageLinks?.thumbnail,
               let url = URL(string: coverURL) {
                do {
                    //TODO: If the image is above a certain size it needs to be resized
                    //add a constant MAX_HEIGHT to this class that determines how large the image should be
                    let data = try Data(contentsOf: url)
                    let cover = UIImage(data: data)
                    return Book(title: title, author: author, cover: cover ?? UIImage(systemName: "book-icon")!)
                } catch {
                    // bummer
                    return nil
                }
            } else {
                let cover = UIImage(systemName: "book")!
                return Book(title: title, author: author, cover: cover)
            }
        })
    }
}
