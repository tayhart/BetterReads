//
//  ViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 3/18/22.
//

import UIKit

class SearchViewController: UIViewController {
    private lazy var searchResultsViewController: SearchResultsCollectionViewController = {
        SearchResultsCollectionViewController(delegate: self)
    }()

    //Toolbar items
    private lazy var homeButton: UIBarButtonItem = {
        var homeIcon = UIImage(systemName: "house")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton()
        let barButton = UIBarButtonItem(
            image: homeIcon,
            style: .plain,
            target: self,
            action: nil)
        barButton.tintColor = .systemTeal
        return barButton
    }()
    private lazy var searchButton: UIBarButtonItem = {
        var icon = UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate)
        let barButton = UIBarButtonItem(
            image: icon,
            style: .plain,
            target: self,
            action: nil)
        barButton.tintColor = .systemMint
        return barButton
    }()
    private lazy var profileButton: UIBarButtonItem = {
        var icon = UIImage(systemName: "person")?.withRenderingMode(.alwaysTemplate)
        let barButton = UIBarButtonItem(
            image: icon,
            style: .plain,
            target: self,
            action: nil)
        barButton.tintColor = .systemPink
        return barButton
    }()
    private var flexButton: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    }

    //Search Bar
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.delegate = self
        bar.placeholder = "Search for a book or author"
        bar.searchBarStyle = .minimal
        bar.tintAdjustmentMode = .normal
        bar.contentMode = .center
        bar.tintColor = .primaryAccentColor
        bar.autocapitalizationType = .words
        return bar
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //Navigation bar Set up
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = false

        toolbarItems = [flexButton, homeButton, flexButton, searchButton, flexButton, profileButton, flexButton]
        navigationController?.setToolbarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(searchBar)
        view.addSubview(searchResultsViewController.collectionView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor),

            searchResultsViewController.collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            searchResultsViewController.collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            searchResultsViewController.collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchResultsViewController.collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    @objc func buttonPressed(sender: UIBarButtonItem) {
        
    }
}

// MARK: -
extension SearchViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else {
            // no-op if query is empty
            return
        }
        searchBar.endEditing(true)
        searchResultsViewController.viewModel.requestData(for: query) { [weak self] in
            self?.searchResultsViewController.applySnapshot()
        }
    }
}

// MARK: - SearchResultsDelegate
extension SearchViewController: SearchResultsDelegate {
    func openVolumeDetails(for volume: GoogleBooksResponse.Volume) {
        let detailsVM = DetailsViewModel(volume)
        let detailsVC = VolumeDetailsViewController(viewModel: detailsVM)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
