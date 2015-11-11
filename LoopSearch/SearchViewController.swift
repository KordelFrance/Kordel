//
//  ViewController.swift
//  LoopSearch
//
//  Created by Kade France on 11/5/15.
//  Copyright © 2015 Kade France. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        //searchBar.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        tableView.rowHeight = 80
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//instantiat a new [String] array and put into searchResults instance variable. Done each time a user performs a search
extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        //make the keyboard disappear after user clicks "search"
        searchBar.resignFirstResponder()
        
        searchResults = [SearchResult]()
        
        if searchBar.text! != "space" {
        for i in 0...2 {
            let searchResult = SearchResult()
            searchResult.name = String(format: "Fake Result %d for ", i)
            
            //comment when integrating indix
            searchResult.artistName = searchBar.text!
            searchResults.append(searchResult)
            }
        }
        hasSearched = true
        tableView.reloadData()
    }
    
    //connect top of search bar to top data bar
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //keep table view empty until user searches for something
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
        return searchResults.count
    }
    }
    
    func tableView (tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if searchResults.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel.text = searchResult.artistName
            return cell
        }
        }
        
        /*let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
        
        //Display "nothing found" if no such match in array
        if searchResults.count == 0 {
            cell.nameLabel.text = "(Nothing Found)"
            cell.artistNameLabel!.text = ""
        } else {
        
        let searchResult = searchResults[indexPath.row]
        cell.nameLabel.text = searchResult.name
        cell.artistNameLabel!.text = searchResult.artistName
        }
        return cell
    }
*/
    
    //these two methods allow cells to be deselected after clicking on them
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}

extension SearchViewController: UITableViewDelegate {
}

