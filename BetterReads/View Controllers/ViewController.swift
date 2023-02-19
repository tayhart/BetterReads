//
//  ViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 3/18/22.
//

import UIKit

//TODO: Rename this. This is the Search Base View Controller
class ViewController: UINavigationController {
    let dataController = DataController()
    var searchResultsViewController = SearchResultsCollectionViewController()

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
        return inputStackView
    }()
    
    private lazy var inputField: UITextField = {
        var searchField = UITextField()
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholder = "Insert Query..."
        
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
        //Navigation bar Set up
        navigationBar.isTranslucent = false
        navigationBar.prefersLargeTitles = true
        title = "Bookish"

        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func setupViews() {
        setToolbarHidden(false, animated: false)
        toolbar.setItems([flexButton, homeButton, flexButton, searchButton, flexButton, profileButton, flexButton], animated: false)

        view.backgroundColor = .white
        view.addSubview(searchBarView)
        view.addSubview(searchResultsViewController.collectionView)

        NSLayoutConstraint.activate([
            searchBarView.heightAnchor.constraint(equalToConstant: 80),
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            searchBarView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),

            searchResultsViewController.collectionView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            searchResultsViewController.collectionView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            searchResultsViewController.collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchResultsViewController.collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            searchResultsViewController.collectionView.heightAnchor.constraint(equalToConstant: 400)
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

