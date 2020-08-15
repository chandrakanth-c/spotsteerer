//
//  SudentEditProfileViewController.swift
//  TestFinalProject
//
//  Created by Chandrakanth on 4/24/20.
//  Copyright © 2020 Pavan Rao. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SudentEditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    
    //Defining all the variables from the View Controller
    @IBOutlet weak var studentNameTextField: UITextField!
    var studentName:String?
    @IBOutlet weak var contactNumberTextField: UITextField!
    var contactNumber:String?
    @IBOutlet weak var emailIdTextField: UITextField!
    var email:String?
    @IBOutlet weak var skillsTextField: UITextField!
    var skills:String?
    @IBOutlet weak var educationDropDown: UIButton!
    var educationOut:String?
    @IBOutlet weak var gpaDropDown: UIButton!
    var gpaOut:String?
    @IBOutlet weak var backgroundDropDown: UITextField!
    var background:String?
    @IBOutlet weak var errorLabel: UILabel!
    
    //Declaration for the dropdown
    let transparentView = UIView()
    var dataSource=[String]()
    let tableView=UITableView()
    var selectedButton = UIButton()
    
    //Storing the values of gpa and education
    var gpa:String = ""
    var education:String = ""
    
    //Initializing a dict variable to store the user and uid
    var dictionaryValues: [String:String] = [:]
    
    //setting a variable for adding or updating
    var isUpdate:Bool?
    var studentProfileId:String?
    
    var db:Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self as? UITableViewDelegate
        tableView.dataSource = self as? UITableViewDataSource
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        //Assigning the initial values on view load
        
        //Assigning email in the start
        emailIdTextField.text = Utilities.emailId
        
        readAndPopulateData()
    }
    
    func readAndPopulateData(){
        
        studentNameTextField.text = studentName
        contactNumberTextField.text = contactNumber
        skillsTextField.text = skills
        backgroundDropDown.text = background
        
        if isUpdate! {
            educationDropDown.setTitle(educationOut, for: .normal)
            gpaDropDown.setTitle(gpaOut, for: .normal)
        }else{
            educationDropDown.titleLabel?.text = "Select Education"
            gpaDropDown.titleLabel?.text = "Select GPA"
        }
        
    }
    
    
    @IBAction func saveActionPerformed(_ sender: Any) {
        
        let error = validateFields()
        
        if error != nil {
            
            showError(error!)
        }else{
            
            let studentName = studentNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let contactNumber = contactNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let emailId = emailIdTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let skills = skillsTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let background = backgroundDropDown.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            db.collection("studentprofile").addDocument(data:["name":studentName, "contactnumber":contactNumber, "emailid":emailId, "skills":skills, "education":education, "gpa": gpa, "background":background ])
        }
        
    }
    
    func validateFields() -> String? {
           
           //Check that all fields are filled in
           if studentNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
              contactNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
              emailIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
              skillsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
              education.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
              gpa.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
              backgroundDropDown.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
               
               return "Please fill in all the fields"
           }
           
           return nil
    }
    
    //Adding the transparent view for the dropdown
    func addTransparentView(frames:CGRect){
            let window = UIApplication.shared.keyWindow
            transparentView.frame=window?.frame ?? self.view.frame
            self.view.addSubview(transparentView)
            
            tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
            self.view.addSubview(tableView)
            tableView.layer.cornerRadius = 5
            
            transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            
            tableView.reloadData()
            
            let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
            transparentView.addGestureRecognizer(tapgesture)
            
            transparentView.alpha=0
            
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                self.transparentView.alpha=0.5
                self.tableView.frame=CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: CGFloat(self.dataSource.count * 50))}, completion: nil)
        }

     //removing the transparentview for the drop down
     @objc func removeTransparentView(){
        
            let frames=selectedButton.frame
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                self.transparentView.alpha=0
                self.tableView.frame=CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
            }, completion: nil)
     }


     @IBAction func onClickEducationDropDown(_ sender: Any) {
            
            let eductionList=["Post Graduate","Graduate","Undergraduate"];
            
            dataSource=eductionList
            selectedButton = educationDropDown
            addTransparentView(frames: educationDropDown.frame)
    }
    
    @IBAction func onClickGpaDropDown(_ sender: Any) {
            
            let gpaList=["1","2","3","4"];
            
            dataSource=gpaList
            selectedButton = gpaDropDown
            addTransparentView(frames: gpaDropDown.frame)
    }
    
    func showError(_ message:String){
           
           errorLabel.text = message
           errorLabel.alpha = 1
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if studentNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           contactNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           emailIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           skillsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           backgroundDropDown.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
           
           let alert = UIAlertController(title: "Incorrect input", message: "None of the fields can be empty!", preferredStyle: UIAlertController.Style.alert)
           alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
           self.present(alert, animated: true, completion: nil)
            
           return false
        }else{
            return true
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let studentName = studentNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let contactNumber = contactNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailId = emailIdTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let skills = skillsTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let background = backgroundDropDown.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isUpdate! {
            
            db.collection("studentprofile").document(studentProfileId ?? "").updateData([
                "name":studentName,
                "contactnumber":contactNumber,
                "skills":skills,
                "education":education,
                "gpa":gpa,
                "background":background
            ])  { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            
        }else{
            db.collection("studentprofile").addDocument(data:["name":studentName, "contactnumber":contactNumber, "emailid":emailId, "skills":skills, "education":education, "gpa": gpa, "background":background ])
        }
        
        if segue.identifier == "UpdateJob" {
            
            if let secondViewController = segue.destination as? SecondViewController{
                
                secondViewController.studentName = studentName
                secondViewController.contactNumber = contactNumber
                secondViewController.email = emailId
                secondViewController.skills = skills
                secondViewController.educationOut = education
                secondViewController.gpaOut = gpa
                secondViewController.backgroundOut = background
            }
        }
    }
    
    
}

extension SudentEditProfileViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let title = selectedButton.titleLabel?.text
        
        if title! == educationOut {
            education = dataSource[indexPath.row]
        }else{
            gpa = dataSource[indexPath.row]
        }
        
        if title! == "Select Education" {
            education = dataSource[indexPath.row]
        }
        
        selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
        removeTransparentView()
    }
}
