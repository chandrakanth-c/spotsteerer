//
//  AppliedJobsTableViewController.swift
//  TestFinalProject
//
//  Created by Pavan Rao on 4/25/20.
//  Copyright © 2020 Pavan Rao. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AppliedJobsTableViewController: UITableViewController {
    
    var jobIdList : [String] = []
    var jobsList : [Job] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jobsList = []
        print(Utilities.appliedJobs.count)
        for id in Utilities.appliedJobs {
            self.db.collection("job").whereField("company", isEqualTo: id).getDocuments{(snapshot, error) in
                if error == nil && snapshot != nil {
                     var newJob = Job()
                    print(snapshot!.documents.count)
                    newJob.company = snapshot!.documents[0].data()["company"] as! String
                    newJob.position = snapshot!.documents[0].data()["position"] as! String
                    self.jobsList.append(newJob)
                    self.tableView.reloadData()
                }
            }
            
        }
        print("Job Id count: \(self.jobsList.count)")
    }

    // MARK: - Table view data source

    @IBAction func refreshAppliedJobs(_ sender: Any) {
        viewDidLoad()
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return jobsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath)
        cell.textLabel?.text = jobsList[indexPath.row].company
        cell.detailTextLabel?.text = jobsList[indexPath.row].position
        return cell
    }

}
