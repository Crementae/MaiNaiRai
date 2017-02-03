//
//  SummerTableViewController.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 12/3/2559 BE.
//  Copyright © 2559 Adisorn Chatnaratanakun. All rights reserved.
//

import UIKit
import SDWebImage

class SummerTableViewController: UITableViewController, UISearchResultsUpdating {
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var summerSeasonData: [Season]? = []
    var searchController: UISearchController!
    var searchResults: [Season]? = []

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationControlelr()
        fetchSummerData()
        configureSpinner()
        
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        
    }
    
    func configureSpinner(){
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        tableView.addSubview(spinner)
        spinner.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchController.searchBar.isHidden = true
        searchController.dismissKeyboard()
    }
    
    
    
    func configureNavigationControlelr() {
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 255.0/255.0, green: 127.0/255.0, blue:0/255.0, alpha: 1.0)
    }
    
    func fetchSummerData(){
        let urlString = "http://rmfl.nagasoftware.com/api/plant_by_season.php?lang_code=1&season_id=1"

        
        LibraryAPI.sharedInstance.fetchSeasonDataFromServer(url: urlString).then { (summerData: [Season]?) -> () in
            self.summerSeasonData = summerData
            print("Success")
            self.spinner.stopAnimating()
            self.tableView.reloadData()
  
        }.catch { (error) in
            print("error \(error)")
        }
    }
    
    func filterText(for searchText: String) {
        
        searchResults = summerSeasonData?.filter({ (summerData) -> Bool in
            
            if let name = summerData.name, let sciName = summerData.scientific_name, let localName = summerData.local_name {
                let isMatch = name.localizedCaseInsensitiveContains(searchText) || sciName.localizedCaseInsensitiveContains(searchText) || localName.localizedCaseInsensitiveContains(searchText)
                
                return isMatch
            }
            return false
        })
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterText(for: searchText)
            tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: nil, action: nil)
        self.navigationController?.hidesBarsOnSwipe = true
        searchController.searchBar.isHidden = false
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
        if summerSeasonData == nil {
            return 0
        }else{
            guard searchController.isActive else{
                return (summerSeasonData?.count)!
            }
            return (searchResults?.count)!
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SummerTableViewCell
        let data = (searchController.isActive) ? searchResults?[indexPath.row] : summerSeasonData?[indexPath.row]
        cell.thumbnail.image = UIImage(named:"photoalbum")
        
        if let urlString = data?.thumbnail {
            let url = NSURL(string: urlString)
            LibraryAPI.sharedInstance.downloadImage(imageURL: url!).then(execute: { (imageThumbnail: UIImage) -> () in
                cell.thumbnail.image = imageThumbnail
                cell.thumbnail.layer.cornerRadius = 30.0
                cell.thumbnail.clipsToBounds = true
            }).catch(execute: { (error) in
                print("error \(error)")
            })
        }
        
        cell.nameLabel.text = data?.name
        cell.sciNameLabel.text = data?.scientific_name
        cell.localNameLabel.text = data?.local_name
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "summerShowDetail" {
            if let indexPath = tableView.indexPathForSelectedRow{
                let data = (searchController.isActive) ? searchResults?[indexPath.row] : summerSeasonData?[indexPath.row]
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    

}
