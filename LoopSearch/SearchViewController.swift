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
        
        //the following code sits inside the if statement so that nothing happens unless the user taps the search bar
        if !searchBar.text!.isEmpty {
        searchBar.resignFirstResponder()
        
        hasSearched = true
        searchResults = [SearchResult]()
        
            let url = urlWithSearchText(searchBar.text!)
            print("URL: '\(url)'")
            
            if let jsonString = performStoreRequestWithURL(url) {
                print("Received JSON string '\(jsonString)'")
                
                //call  the parseJSON method and print return value
                if let dictionary = parseJSON(jsonString) {
                    print("Dictionary \(dictionary)")
                    
                    //call parseDictionary method below
                    parseDictionary(dictionary)
                    tableView.reloadData()
                    return
                }
            }

        showNetworkError()
        }
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
    
    func urlWithSearchText(searchText: String) -> NSURL {
        
        //this statement calls the stringByAdding... method to escape the "special characters" induced crash such as spaces
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let urlString = String(format:  "https://api.semantics3.com/test/v1/", escapedSearchText)
        let url = NSURL(string: urlString)
        return url!
    }
    //https://itunes.apple.com/search?term=%@
    
    func performStoreRequestWithURL(url: NSURL) -> String? {
        do {
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        } catch {
            print("Download Error: \(error)")
                return nil
        }
    }
    
    //convert java script to readable text and store in dictionary
    func parseJSON(jsonString: String) -> [String: AnyObject]? {
        guard let data =  jsonString.dataUsingEncoding(NSUTF8StringEncoding) else { return nil }
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print ("JSON Error: \(error)")
            return nil
        }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "WHoops...", message: "There was an error reading from iTunes Store, Please Try again.", preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func parseDictionary(dictionary: [String: AnyObject]) {
        
        //1 make sure the dictionary has a key named results that contains an array
        guard let array = dictionary["results"] as? [AnyObject] else {
            print ("Expected 'results' array")
            return
        }
        
        //2 lppk at each of the array's elements
        for resultDict in array {
            
            //3 cast objects to the right type (coming from an Obj-C library)
            if let resultDict = resultDict as? [String: AnyObject] {
             
                //4 print out the value of wrapperType and kind fields
                if let wrapperType = resultDict ["wrapperType"] as? String,
                    let kind = resultDict["kind"] as? String {
                        print("wrapperType: \(wrapperType), kind: \(kind)")
                }
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate {
}






