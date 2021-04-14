//
//  SearchViewController.swift
//  Remindew
//
//  Created by Jorge Alvarez on 1/2/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import UIKit

protocol SelectedResultDelegate {
    /// Passes back PlantSearchResult that's selected in SearchViewController
    func didSelectResult(searchResult: PlantSearchResult, image: UIImage?)
}

class SearchViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var tableView: UITableView!
    
    /// Temporarily holds search results received from search
    var plantSearchResults: [PlantSearchResult] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var resultDelegate: SelectedResultDelegate?
    
    /// Loading indicator displayed while searching for a plant
    let spinner = UIActivityIndicatorView(style: .large)
    
    /// plantController passed in from DetailVC
    var plantController: PlantController?
    
    /// Passed in when we come from DetailVC (hitting "search" in it's speciesTextfield)
    var passedInSearchTerm: String? {
        didSet {
            updateViews()
        }
    }

    /// Setup tableView, searchBar, and then update views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureSearchBar()
        updateViews()
    }
    
    /// Sets up tableView
    private func configureTableView() {
     
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        tableView.keyboardDismissMode = .onDrag
        tableView.isHidden = true
        tableView.backgroundView = spinner
        spinner.color = .leafGreen
    }
    
    /// Sets up searchBar
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search by plant name, species, etc", comment: "")
        searchBar.tintColor = .mixedBlueGreen
    }
        
    /// User (or DetailVewController) pressed "search"
    func didTapSearch() {
        
        // dismiss keyboard (if it's still up)
        searchBar.resignFirstResponder()
        
        // if there's still a search going on, exit out
        if spinner.isAnimating {
            return
        }
        
        guard let unwrappedTerm = searchBar.text, !unwrappedTerm.isEmpty else { return }
        
        // get rid of any spaces in search term
        let term = unwrappedTerm.replacingOccurrences(of: " ", with: "")
        
        // show tableview
        tableView.isHidden = false

        // start animating spinner
        spinner.startAnimating()

        // check if we need a new token first
        if plantController?.newTempTokenIsNeeded() == true {
            
            plantController?.signToken(completion: { (result) in
                do {
                    let message = try result.get()
                    DispatchQueue.main.async {
                        print("success in signToken: \(message)")
                        self.performPlantSearch(term)
                    }
                } catch {
                    if let error = error as? NetworkError {
                        print("error in detailVC when signing token")
                        DispatchQueue.main.async {
                            self.spinner.stopAnimating()
                            self.handleNetworkErrors(error)
                        }
                    }
                }
            })
        }

        // No new token needed
        else {
            performPlantSearch(term)
        }
    }
    
    // MARK: - Networking
        
    /// Presents custom alerts for given network error
    func handleNetworkErrors(_ error: NetworkError) {
        switch error {
        case .badAuth:
            print("badAuth in signToken")
        case .noToken:
            print("no token in searchPlants")
        case .invalidURL:
            UIAlertController.makeAlert(title: NSLocalizedString("Invalid Species", comment: ".invalidURL"),
                                        message: NSLocalizedString("Please enter a valid species name", comment: "invalid URL"),
                                        vc: self)
            return
        case .otherError:
            print("other error in searchPlants")
        case .noData:
            print("No data received or data corrupted")
        case .noDecode:
            print("JSON could not be decoded")
        case .invalidToken:
            print("personal token invalid when sending to get temp token url")
        case .serverDown:
            UIAlertController.makeAlert(title: NSLocalizedString("Server Maintenance", comment: "Title for Servers down temporarily"),
                                        message: NSLocalizedString("Servers down for maintenance. Please try again later.", comment: "Servers down"),
                                        vc: self)
            return
        default:
            print("default error in searchPlants")
        }
        
        // Error for all cases that don't have custom ones
        UIAlertController.makeAlert(title: NSLocalizedString("Network Error", comment: "any network error"),
                                    message: NSLocalizedString("Search feature temporarily unavailable", comment: "any network error"),
                                    vc: self)
    }
    
    /// Performs a search for plants species (called inside textfield Return)
    func performPlantSearch(_ term: String) {
        self.plantController?.searchPlantSpecies(term, completion: { (result) in
            
            do {
                let plantResults = try result.get()
                DispatchQueue.main.async {
                    self.plantSearchResults = plantResults
                    self.spinner.stopAnimating()
                    if plantResults.count == 0 {
                        UIAlertController.makeAlert(title: NSLocalizedString("No Results Found",
                                                                comment: "no search resutls"),
                                                    message: NSLocalizedString("Please search for another species",
                                                                  comment: "try another species"),
                                                    vc: self)
                    }
                }
                
            } catch {
                if let error = error as? NetworkError {
                    DispatchQueue.main.async {
                        print("Error searching for plants in performPlantSearch")
                        self.spinner.stopAnimating()
                        self.handleNetworkErrors(error)
                    }
                }
            }
        })
    }
    
    private func updateViews() {
        
        guard isViewLoaded else { return }
        
        searchBar.text = passedInSearchTerm
        
        if passedInSearchTerm == nil || passedInSearchTerm == "" {
            searchBar.becomeFirstResponder()
            return
        }
        
        didTapSearch()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plantSearchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Cast as a custom tableview cell (after I make one)
        guard let resultCell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell() }

        let plantResult = plantSearchResults[indexPath.row]//plantController?.plantSearchResults[indexPath.row]

        // common name
        resultCell.commonNameLabel.text = plantResult.commonName?.capitalized ?? "-"

        // scientific name
        resultCell.scientificNameLabel.text = plantResult.scientificName ?? "-"

        resultCell.spinner.startAnimating()
        // image
        // store returned UUID? for task for later
        let token = plantController?.loadImage(plantResult.imageUrl) { result in
            do {

                // extract result (UIImage)
                let image = try result.get()

                // if we get an image, display in cell's image view on main queue
                DispatchQueue.main.async {
                    resultCell.plantImageView?.image = image
                    resultCell.spinner.stopAnimating()
                }
            } catch {
                // do something if there's an error
                // set image to default picture?
                print("Error in result of loadImage in cellForRowAt")
                DispatchQueue.main.async {
                    resultCell.plantImageView?.image = .logoImage
                    resultCell.spinner.stopAnimating()
                }
            }
        }

        // use UUID? we just made to now cancel the load for it
        resultCell.onReuse = {
            // when cell is reused, try to cancel the task it started here
            if let token = token {
                resultCell.spinner.stopAnimating()
                self.plantController?.cancelLoad(token)
            }
        }

        return resultCell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        let plantResultCell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell

        let plantResult = plantSearchResults[indexPath.row]
        resultDelegate?.didSelectResult(searchResult: plantResult, image: plantResultCell?.plantImageView.image)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        didTapSearch()
        return
    }
}
