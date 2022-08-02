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
    var searchResults: SearchResultsViewController = SearchResultsViewController()

    //Toolbar items
    private lazy var homeButton: UIBarButtonItem = {
        var homeIcon = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton()
        button.setImage(homeIcon?.withTintColor(.systemTeal, renderingMode: .automatic), for: .normal)
        button.setImage(homeIcon?.withTintColor(.systemPink, renderingMode: .alwaysTemplate), for: .selected)
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        let barButton = UIBarButtonItem(customView: button)
        return barButton
    }()
    private lazy var searchButton: UIBarButtonItem = {
        var icon = UIImage(named: "search")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton()
        button.setImage(icon?.withTintColor(.systemTeal, renderingMode: .automatic), for: .normal)
        button.setImage(icon?.withTintColor(.systemPink, renderingMode: .alwaysTemplate), for: .selected)
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        let barButton = UIBarButtonItem(customView: button)
        return barButton
    }()
    private lazy var profileButton: UIBarButtonItem = {
        var icon = UIImage(named: "profile")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton()
        button.setImage(icon?.withTintColor(.systemTeal, renderingMode: .automatic), for: .normal)
        button.setImage(icon?.withTintColor(.systemPink, renderingMode: .alwaysTemplate), for: .selected)
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        let barButton = UIBarButtonItem(customView: button)
        return barButton
    }()
    private var flexButton: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    }
    
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
        toolbar.items = [flexButton, homeButton, flexButton, searchButton, flexButton, profileButton, flexButton]

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
            searchBarView.topAnchor.constraint(equalTo: navigationBar.topAnchor),
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

