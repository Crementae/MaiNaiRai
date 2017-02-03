//
//  ColdTableViewController.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 12/3/2559 BE.
//  Copyright © 2559 Adisorn Chatnaratanakun. All rights reserved.
//

import UIKit

class ColdTableViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet var spinner:UIActivityIndicatorView!
    
    var coldSeasonData: [Season]? = []
    var searchController: UISearchController!
    var searchResults: [Season]? = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 15.0/255.0, green: 239.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        fetchColdSeasonData()
        configureSpinner()
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
    
    }
    
    func configureSpinner(){
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        tableView.addSubview(spinner)
        spinner.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: nil, action: nil)
        searchController.searchBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchController.searchBar.isHidden = true
        searchController.dismissKeyboard()
    }
    
    func filterSearchText(for searchText: String) {
        searchResults = coldSeasonData?.filter({ (coldData) -> Bool in
            if let name = coldData.name, let sciName = coldData.scientific_name, let localName = coldData.local_name {
                let isMatch = name.localizedCaseInsensitiveContains(searchText) || sciName.localizedCaseInsensitiveContains(searchText) || localName.localizedCaseInsensitiveContains(searchText)
                return isMatch
            }
            return false
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterSearchText(for: searchText)
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if coldSeasonData == nil {
            return 0
        }else{
            guard searchController.isActive else {
                return (coldSeasonData?.count)!
            }
            return (searchResults?.count)!
        }
    }
    
    func fetchColdSeasonData() {
        let urlString = "http://rmfl.nagasoftware.com/api/plant_by_season.php?lang_code=1&season_id=3"
        
        LibraryAPI.sharedInstance.fetchSeasonDataFromServer(url: urlString).then { (coldSeason: [Season]?) -> () in
            self.coldSeasonData = coldSeason
            self.spinner.stopAnimating()
            self.tableView.reloadData()

        }.catch { (error) in
            print("Error: \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ColdTableViewCell
        let data = (searchController.isActive) ? searchResults?[indexPath.row] : coldSeasonData?[indexPath.row]
        
        if let urlThumbnail = data?.thumbnail {
            let url = NSURL(string: urlThumbnail)
            LibraryAPI.sharedInstance.downloadImage(imageURL: url!).then(execute: { (thumnailImage: UIImage) -> () in
                cell.thumbnail.image = thumnailImage
                cell.thumbnail.layer.cornerRadius = 30.0
                cell.thumbnail.clipsToBounds = true
                
            }).catch(execute: { (error) in
                print("Error: \(error)")
            })
            
            cell.nameLabel.text = data?.name
            cell.sciNameLabel.text = data?.scientific_name
            cell.localNameLabel.text = data?.local_name
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showColdSeasonDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let data = (searchController.isActive) ? searchResults?[indexPath.row] : coldSeasonData?[indexPath.row]
                let destination = segue.destination as! DetailViewController
                destination.seasonData = data
                
                if let urlString = data?.thumbnail{
                    let url = NSURL(string: urlString)
                    LibraryAPI.sharedInstance.downloadImage(imageURL: url!).then(execute: { (thumbnail:UIImage) -> () in
                        destination.thumbnailImage = thumbnail
                    }).catch(execute: { (error) in
                        print("Error: \(error)")
                    })
                }
                
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }



}
