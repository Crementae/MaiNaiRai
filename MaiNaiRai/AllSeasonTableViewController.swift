//
//  SummerTableViewController.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 12/1/2559 BE.
//  Copyright © 2559 Adisorn Chatnaratanakun. All rights reserved.
//

import UIKit
import SDWebImage


class AllSeasonTableViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var allSeason: [Season]? = []
    var searchController = UISearchController()
    var searchResults: [Season]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        configureNavigationBar()
        fetchSummerSeasonData()
        configureSpinner()
    }
    
    func configureSpinner() {
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        tableView.addSubview(spinner)
        spinner.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchController.searchBar.isHidden = true
        searchController.dismissKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem!.tintColor = UIColor.white
        self.navigationController?.hidesBarsOnSwipe = true
        searchController.searchBar.isHidden = false
    }
    
    func configureNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 52.0/255.0, green: 164.0/255.0, blue: 70.0/255.0, alpha: 1.0)
        
    }
    
    func filterSearch(for searchText: String) {
        searchResults = allSeason?.filter({ (allSeason) -> Bool in
            if let name = allSeason.name, let sciName = allSeason.scientific_name, let localName = allSeason.local_name {
                let isMatch = name.localizedCaseInsensitiveContains(searchText) || sciName.localizedCaseInsensitiveContains(searchText) || localName.localizedCaseInsensitiveContains(searchText)
                return isMatch
            }
            return false
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterSearch(for: searchText)
            tableView.reloadData()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSeasonDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let data = (searchController.isActive) ? searchResults?[indexPath.row] : allSeason?[indexPath.row]
                let destination = segue.destination as! DetailViewController
                destination.seasonData = data
                
                if let urlString = data?.thumbnail {
                    let url = NSURL(string: urlString)
                    LibraryAPI.sharedInstance.downloadImage(imageURL: url!).then(execute: { (thumbnail: UIImage) -> () in
                        destination.thumbnailImage = thumbnail
                    }).catch(execute: { (error) in
                        print("Error: \(error)")
                    })
                }
            }
        }
    }
    
    
    
    func fetchSummerSeasonData() {
        
        let url = "http://rmfl.nagasoftware.com/api/plant_by_season.php?lang_code=1&season_id=0"
        
        
        LibraryAPI.sharedInstance.fetchSeasonDataFromServer(url: url).then { (season: [Season]?) -> () in
            
            print("Success")
            self.allSeason = season
            self.spinner.stopAnimating()
            self.tableView.reloadData()

            
            }.always {() -> () in
                
            }.catch { (error) -> () in
                print("error: \(error)")
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
        
        if allSeason?.count == nil {
            return 0
        }else{
            if searchController.isActive {
                return searchResults!.count
            }else{
                return allSeason!.count
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AllSeasonTableViewCell
        let data = (searchController.isActive) ? searchResults?[indexPath.row] : allSeason?[indexPath.row]
        cell.nameLabel.text = data?.name
        cell.localNameLabel.text = data?.local_name
        cell.sciNameLabel.text = data?.scientific_name
        cell.thumbnail.image = UIImage(named: "photoalbum")
        
        if let urlString = data?.thumbnail {
            let url = NSURL(string: urlString)
            
            LibraryAPI.sharedInstance.downloadImage(imageURL: url!).then(execute: { (image: UIImage) -> () in
                cell.thumbnail.image = image
                cell.thumbnail.layer.cornerRadius = 30.0
                cell.thumbnail.clipsToBounds = true
            }).catch(execute: { (error) in
                print("error: \(error)")
            })
        
        }
        
        return cell
    }
}

