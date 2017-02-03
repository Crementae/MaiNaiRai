//
//  RainTableViewController.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 12/3/2559 BE.
//  Copyright © 2559 Adisorn Chatnaratanakun. All rights reserved.
//

import UIKit


class RainTableViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var rainSeasonData:[Season]? = []
    var searchController: UISearchController!
    var searchResults:[Season]? = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 69.0/255.0, green: 181/255.0, blue: 255.0/255.0, alpha: 1.0)
        fetchRainniSeasonData()
        
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        
        configureSpinner()

    }
    
    func configureSpinner(){
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        tableView.addSubview(spinner)
        spinner.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchController.searchBar.isHidden = true
        searchController.dismissKeyboard()
    }
    
    func filterSearchResult(for searchText: String){
        searchResults = rainSeasonData?.filter({ (rainData) -> Bool in
            if let name = rainData.name, let sciName = rainData.scientific_name, let localName = rainData.local_name {
                let isMatch = name.localizedCaseInsensitiveContains(searchText) || sciName.localizedCaseInsensitiveContains(searchText) || localName.localizedCaseInsensitiveContains(searchText)
                return isMatch
            }
            return false
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterSearchResult(for: searchText)
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
        if rainSeasonData == nil {
            return 0
        }else{
            guard searchController.isActive else{
                return (rainSeasonData?.count)!
            }
            return (searchResults?.count)!
        }
        
    }
    
    func fetchRainniSeasonData(){
        
        let urlString = "http://rmfl.nagasoftware.com/api/plant_by_season.php?lang_code=1&season_id=2"
        
        LibraryAPI.sharedInstance.fetchSeasonDataFromServer(url: urlString).then {
            (rainnyData: [Season]?) -> () in
            
            self.rainSeasonData = rainnyData
            self.spinner.stopAnimating()
            self.tableView.reloadData()
       
        }.catch { (error) in
            print("Error: \(error)")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RainTableViewCell
        let data = (searchController.isActive) ? searchResults?[indexPath.row] : rainSeasonData?[indexPath.row]
        
        if let urlString = data?.thumbnail{
            let url = NSURL(string: urlString)
            LibraryAPI.sharedInstance.downloadImage(imageURL: url!).then(execute: { (thumbnail: UIImage) -> () in
                cell.thumbnail.image = thumbnail
                cell.thumbnail.layer.cornerRadius = 30.0
                cell.thumbnail.clipsToBounds = true
                
            }).catch(execute: { (error) in
                print("error: \(error)")
            })
        }
        
        cell.nameLabel.text = data?.name
        cell.sciNameLabel.text = data?.scientific_name
        cell.localNameLabel.text = data?.local_name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showRainnyDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let data = (searchController.isActive) ? searchResults?[indexPath.row] : rainSeasonData?[indexPath.row]
                let destination = segue.destination as! DetailViewController
                destination.seasonData = data
                
                if let urlString = data?.thumbnail {
                    let url = NSURL(string:urlString)
                    LibraryAPI.sharedInstance.downloadImage(imageURL: url!).then(execute: { (thumbnail:UIImage) -> () in
                        destination.thumbnailImage = thumbnail
                    }).catch(execute: { (error) in
                        print("Error: \(error)")
                    })
                }
            }
        }
    }
}
