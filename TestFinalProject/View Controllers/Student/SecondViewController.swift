//
//  SecondViewController.swift
//  TestFinalProject
//
//  Created by Pavan Rao on 4/22/20.
//  Copyright © 2020 Pavan Rao. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

extension SecondViewController {
    @IBAction func saveUpdatedStudentProfile(_ segue: UIStoryboardSegue) {
        guard
            segue.source is SudentEditProfileViewController
           else {
             return
         }
        viewDidLoad()
    }
    
    @IBAction func cancelUpdateStudentProfile(_ segue: UIStoryboardSegue) {
        guard
            segue.source is SudentEditProfileViewController
           else {
             return
         }
    }
}

class SecondViewController: UIViewController {
    
    //variables from the second view controller
    @IBOutlet weak var studentNameLabel: UILabel!
    var studentName:String?
    @IBOutlet weak var contactNumberLabel: UILabel!
    var contactNumber:String?
    @IBOutlet weak var emailIdLabel: UILabel!
    var email:String?
    @IBOutlet weak var skillsLabel: UILabel!
    var skills:String?
    @IBOutlet weak var educationLabel: UILabel!
    var educationOut:String?
    @IBOutlet weak var gpaLabel: UILabel!
    var gpaOut:String?
    @IBOutlet weak var backgroundLabel: UILabel!
    var backgroundOut:String?
    @IBOutlet weak var editProfileButton: UIButton!
    
    var studentProfileId:String?
    
    var db:Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        studentNameLabel.text = studentName
        contactNumberLabel.text = contactNumber
        emailIdLabel.text = email
        skillsLabel.text = skills
        educationLabel.text = educationOut
        gpaLabel.text = gpaOut
        backgroundLabel.text = backgroundOut
        
        db = Firestore.firestore()
        
        readAndPopulateData()
    }
    
    func readAndPopulateData(){
        
        db.collection("studentprofile").whereField("emailid", isEqualTo: Utilities.emailId)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        self.studentProfileId = "\(document.documentID)"
                        self.studentNameLabel.text = "\(document.data()["name"] ?? "")"
                        self.contactNumberLabel.text = "\(document.data()["contactnumber"] ?? "")"
                        self.emailIdLabel.text = "\(document.data()["emailid"] ?? "")"
                        self.skillsLabel.text = "\(document.data()["skills"] ?? "")"
                        self.educationLabel.text = "\(document.data()["education"] ?? "")"
                        self.gpaLabel.text = "\(document.data()["gpa"] ?? "")"
                        self.backgroundLabel.text = "\(document.data()["background"] ?? "")"
                        
                    }
                }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "UpdateStudentProfile" {
            
            if let studentEditProfile = segue.destination as? SudentEditProfileViewController {
                studentEditProfile.studentProfileId = studentProfileId
                studentEditProfile.studentName = studentNameLabel.text
                studentEditProfile.contactNumber = contactNumberLabel.text
                studentEditProfile.skills = skillsLabel.text
                studentEditProfile.educationOut = educationLabel.text ?? ""
                studentEditProfile.gpaOut = gpaLabel.text ?? ""
                studentEditProfile.background = backgroundLabel.text
                
                if studentNameLabel.text == nil {
                    studentEditProfile.isUpdate = false
                }else{
                    studentEditProfile.isUpdate = true
                }
            }
        }
    }
}

