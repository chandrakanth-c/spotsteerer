//
//  StudentJobListViewController.swift
//  TestFinalProject
//
//  Created by Pavan Rao on 4/25/20.
//  Copyright © 2020 Pavan Rao. All rights reserved.
//

import UIKit
import FirebaseFirestore

extension StudentJobListViewController {
    
    @IBAction func updateJobStatus(_ segue: UIStoryboardSegue) {
        guard
            segue.source is JobAddViewController || segue.source is JobDisplayViewController
           else {
             return
         }
//        db.collection("products").get()
//        .then(res => {
//          vm.mainListItems = [];
//          res.forEach(doc => {
//            let newItem = doc.data();
//            newItem.id = doc.id;
//            if (newItem.userRef) {
//              newItem.userRef.get()
//              .then(res => {
//                newItem.userData = res.data()
//                vm.mainListItems.push(newItem);
//              })
//              .catch(err => console.error(err));
//            } else {
//              vm.mainListItems.push(newItem);
//            }
//
//          });
//        })
//        .catch(err => { console.error(err) });
        loadData()
    }
}

extension StudentJobListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    // TODO
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)

  }
}

class StudentJobListViewController: UITableViewController, UISearchBarDelegate {

    let db = Firestore.firestore()
    var count: Int = 0
    var jobsList : [Job] = []
    var filteredJobsList : [Job] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Job by Company name"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        self.definesPresentationContext = true
        loadData()
    }

    func loadData() {
        db.collection("job").order(by: "company").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.count = querySnapshot?.count ?? 0
                self.jobsList = []
                var newJob = Job(company: "", position: "", location: "", link: "", deadline: "")
                for document in querySnapshot!.documents {
                    newJob.company = document.data()["company"] as! String
                    newJob.position = document.data()["position"] as! String
                    newJob.link = document.data()["link"] as! String
                    newJob.deadline = document.data()["deadline"] as! String
                    newJob.location = document.data()["location"] as! String
                    newJob.jobId = document.documentID
                    newJob.companyLogo = document.data()["companyLogo"] as! String
                    self.jobsList.append(newJob)
                }
            }
            
            self.tableView.reloadData()

        }
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredJobsList = jobsList.filter {
            (job: Job) -> Bool in
            return job.company.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredJobsList.count
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath)
        cell.imageView?.image = UIImage(named: "logo")
        cell.imageView?.contentMode = .scaleAspectFit
        if isFiltering {
            cell.textLabel?.text = self.filteredJobsList[indexPath.row].company
            cell.detailTextLabel?.text = self.filteredJobsList[indexPath.row].position
            
        }
        else {
            cell.textLabel?.text = jobsList[indexPath.row].company
            cell.detailTextLabel?.text = jobsList[indexPath.row].position
            let logoUrl = jobsList[indexPath.row].companyLogo
            if logoUrl != ""{
                let url = URL(string: logoUrl)!
                print("Download Started")
                getData(from: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    print(response?.suggestedFilename ?? url.lastPathComponent)
                    print("Download Finished")
                    DispatchQueue.main.async() {
                        
                        cell.imageView?.image = UIImage(data: data)
                    }
                }
            }
            
        }
        
        return cell
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = tableView.indexPathForSelectedRow
        if segue.identifier == "StudentJobDetail" {
            if let jobDisplayViewController = segue.destination as? StudentJobDisplayViewController {
                var job = Job()
                if isFiltering {
                    job = self.filteredJobsList[index?.row ?? 0]
                }
                else {
                    job = self.jobsList[index?.row ?? 0]
                }
                jobDisplayViewController.companyField = job.company
                jobDisplayViewController.deadlineField = job.deadline
                jobDisplayViewController.linkField = job.link
                jobDisplayViewController.locationField = job.location
                jobDisplayViewController.positionField = job.position
                jobDisplayViewController.jobIdField = job.jobId
                jobDisplayViewController.imageURL = job.companyLogo
            }
        }
    }
    
}


