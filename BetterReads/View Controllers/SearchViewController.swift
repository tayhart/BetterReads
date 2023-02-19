//
//  ViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 3/18/22.
//

import UIKit

class SearchViewController: UIViewController {
    let dataController = BooksDataController()
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

    // The container for the input text field and search button
    private lazy var searchBarView: UIStackView = {
        let inputStackView = UIStackView(arrangedSubviews: [inputField, initiateQueryButton])
        inputStackView.axis = .horizontal
        inputStackView.translatesAutoresizingMaskIntoConstraints = false
        inputStackView.backgroundColor = .white
        inputStackView.distribution = .fillProportionally
        return inputStackView
    }()
    
    private lazy var inputField: UITextField = {
        var searchField = UITextField()
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholder = "Insert Query..."
        searchField.clearButtonMode = .whileEditing
        return searchField
    }()

    private lazy var initiateQueryButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Search", for: .normal)
        button.tintColor = .systemMint
        button.addAction(UIAction(handler: {[weak self] _ in
            self?.didPressSearchButton()
        }), for: .touchUpInside)
        return button
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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(searchBarView)
        view.addSubview(searchResultsViewController.collectionView)

        NSLayoutConstraint.activate([
            searchBarView.heightAnchor.constraint(equalToConstant: 80),
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            searchBarView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),

            searchResultsViewController.collectionView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            searchResultsViewController.collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            searchResultsViewController.collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchResultsViewController.collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func didPressSearchButton() {
        guard let query = inputField.text else {
            print("NOTHING TO SHOW")
            return
        }
        dataController.request(query, completion: {
            searchResult in
            self.searchResultsViewController.populateWithData(responseData: searchResult)
        })
    }

    @objc func buttonPressed(sender: UIBarButtonItem) {
        
    }
}

extension SearchViewController: SearchResultsDelegate {
    func didSelectItem(_ book: Book) {
        let detailsVC = VolumeDetailsViewController(with: book)
        navigationController?.pushViewController(detailsVC, animated: true)
    }

}

