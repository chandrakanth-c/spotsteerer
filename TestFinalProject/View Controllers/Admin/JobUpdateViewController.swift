//
//  JobUpdateViewController.swift
//  TestFinalProject
//
//  Created by Pavan Rao on 4/24/20.
//  Copyright © 2020 Pavan Rao. All rights reserved.
//

import UIKit
import FirebaseFirestore

class JobUpdateViewController: UIViewController {

    let db = Firestore.firestore()
    
    @IBOutlet weak var jobIdLabel: UILabel!
    var jobIdField: String?
    
    @IBOutlet weak var locationLabel: UILabel!
    var locationField: String?
    
    @IBOutlet weak var companyLabel: UILabel!
    var companyField: String?
    
    @IBOutlet weak var positionText: UITextField!
    var positionField: String?
    
    @IBOutlet weak var deadlineText: UITextField!
    var deadlineField: String?
    
    @IBOutlet weak var linkText: UITextField!
    var linkField: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jobIdLabel.text = jobIdField
        positionText.text = positionField
        companyLabel.text = companyField
        locationLabel.text = locationField
        deadlineText.text = deadlineField
        linkText.text = linkField
        // Do any additional setup after loading the view.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "UpdateJob" {
            if (positionText.text == "" || companyLabel.text == "" || locationLabel.text == "" ||  deadlineText.text == "" || linkText.text == "") {
                let alert = UIAlertController(title: "Incorrect input", message: "None of the fields can be empty!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        db.collection("job").document(jobIdField ?? "").updateData([
            "position": positionText.text ?? "",
            "deadline": deadlineText.text ?? "",
            "link": linkText.text ?? ""
        ])  { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        if segue.identifier == "UpdateJob" {
            if let jobDisplayViewController = segue.destination as? JobDisplayViewController {
                jobDisplayViewController.companyField = companyLabel.text
                jobDisplayViewController.deadlineField = deadlineText.text
                jobDisplayViewController.positionField = positionText.text
                jobDisplayViewController.linkField = linkText.text
                jobDisplayViewController.locationField = locationLabel.text
                Utilities.appliedJobs.append(jobIdLabel.text!)
            }
        }
    }
    
}
