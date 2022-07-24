//
//  ViewController.swift
//  mibrary
//
//  Created by Taylor Hartman on 3/18/22.
//

import UIKit

//TODO: Rename this. This is the Search Base View Controller
class ViewController: UINavigationController {
    let dataController = DataController()
    var searchResults: SearchResultsViewController = SearchResultsViewController()

    //Toolbar items
    let lists = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: nil)
    let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
    let profile = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: nil)
    let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(buttonPressed(sender:)))
    
    lazy var searchBarView: UIStackView = {
        let inputStackView = UIStackView()
        inputStackView.axis = .horizontal
        inputStackView.translatesAutoresizingMaskIntoConstraints = false
        return inputStackView
    }()
    
    let inputField: UITextField = {
        var searchField = UITextField()
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholder = "Insert Query..."
        
        return searchField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        //Navigation bar Set up
        navigationBar.isTranslucent = false
        navigationBar.prefersLargeTitles = true

        self.view.backgroundColor = .white
        self.view.addSubview(searchBarView)
        searchBarView.backgroundColor = .white

        setToolbarHidden(false, animated: false)
        toolbar.backgroundColor = .white
        toolbar.items = [flexButton, profile, lists, searchButton, flexButton]

        self.view.addSubview(searchResults.collectionView)
        
        let searchButton = UIButton(type: .system)
        searchButton.setTitle("Search", for: .normal)
        searchButton.addAction(UIAction(handler: {_ in
            self.didPressSearchButton()
        }), for: .touchUpInside)
        
        searchBarView.addArrangedSubview(inputField)
        searchBarView.addArrangedSubview(searchButton)

        NSLayoutConstraint.activate([
            inputField.widthAnchor.constraint(equalToConstant: 240),
            searchBarView.heightAnchor.constraint(equalToConstant: 80),
            searchBarView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            searchBarView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            searchBarView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 15),
            searchResults.collectionView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            searchResults.collectionView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            searchResults.collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchResults.collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func didPressSearchButton() {
        guard let query = inputField.text else {
            print("NOTHING TO SHOW")
            return
        }
        dataController.request(query, completion: {
            searchResult in
            self.searchResults.populateWithData(responseData: searchResult)
        })
    }

    @objc func buttonPressed(sender: UIBarButtonItem) {
        
    }
}

