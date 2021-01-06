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
    func didSelectResult(searchResult: PlantSearchResult)
}

class SearchViewController: UIViewController {
    
//    /// Searchbar that takes in species/plant name
//    let searchBar: UISearchBar = {
//        let bar = UISearchBar()
//        bar.translatesAutoresizingMaskIntoConstraints = false
//        bar.backgroundColor = .green
//        return bar
//    }()
//
//    /// TableView that displays search results
//    let tableView: UITableView = {
//        let table = UITableView()
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.backgroundColor = .systemPink
//        return table
//    }()
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var tableView: UITableView!
    
    /// Temporarily holds search results received from search
    var plantSearchResults: [PlantSearchResult] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    /// Loading indicator displayed while searching for a plant
    let spinner = UIActivityIndicatorView(style: .large)
    
    /// plantController passed in from DetailVC
    var plantController: PlantController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        tableView.backgroundView = spinner
        spinner.color = .leafGreen
        tableView.isHidden = true
                
        updateViews()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Networking
    
    /// Makes custom alerts with given title and message for network errors
    private func makeAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Presents custom alerts for given network error
    func handleNetworkErrors(_ error: NetworkError) {
        switch error {
        case .badAuth:
            print("badAuth in signToken")
        case .noToken:
            print("no token in searchPlants")
        case .invalidURL:
            makeAlert(title: NSLocalizedString("Invalid Species", comment: ".invalidURL"),
                      message: NSLocalizedString("Please enter a valid species name", comment: "invalid URL"))
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
            makeAlert(title: NSLocalizedString("Server Maintenance", comment: "Title for Servers down temporarily"),
                      message: NSLocalizedString("Servers down for maintenance. Please try again later.", comment: "Servers down"))
            return
        default:
            print("default error in searchPlants")
        }
        // Error for all cases that don't have custom ones
        makeAlert(title: NSLocalizedString("Network Error", comment: "any network error"),
                  message: NSLocalizedString("Search feature temporarily unavailable", comment: "any network error"))
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
                        self.makeAlert(title: NSLocalizedString("No Results Found",
                                                                comment: "no search resutls"),
                                       message: NSLocalizedString("Please search for another species",
                                                                  comment: "try another species"))
                    }
                    print("set array to plants we got back")
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
    
//    private func setupSubviews() {
//        view.backgroundColor = .yellow
//        
//        // Searchbar
//        view.addSubview(searchBar)
//        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
//        searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
//        searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
//        
//        // TableView
//        view.addSubview(tableView)
//        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
//        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
//        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
////        tableView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5).isActive = true
//        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
//    }
    
    private func updateViews() {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plantSearchResults.count//(plantController?.plantSearchResults.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Cast as a custom tableview cell (after I make one)
        guard let resultCell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell() }

        let plantResult = plantSearchResults[indexPath.row]//plantController?.plantSearchResults[indexPath.row]

        // common name
        resultCell.commonNameLabel.text = plantResult.commonName?.capitalized ?? "No common name"

        // scientific name
        resultCell.scientificNameLabel.text = plantResult.scientificName ?? "No scientific name"

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
//        let scientificName = plantResultCell?.scientificNameLabel.text ?? ""
//        imageView.image = plantResultCell?.plantImageView.image
//
        // if we DO want it to put common name selected into species field
        if UserDefaults.standard.bool(forKey: .resultFillsSpeciesTextfield) && plantResultCell?.commonNameLabel.text != "No common name"{
            //speciesTextField.text = plantResultCell?.commonNameLabel.text
        }
//        
    }
    
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Clicked "Search" in searchbar
        if searchBar == self.searchBar {
            print("Return inside speciesTextfield")

            // dismiss keyboard
            searchBar.resignFirstResponder()
            
            // if there's still a search going on, exit out
            if spinner.isAnimating {
                print("still spinning")
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
                print("new token needed, fetching one first")
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
                print("No token needed, searching")
                performPlantSearch(term)
            }
        }

        return
    }
}
