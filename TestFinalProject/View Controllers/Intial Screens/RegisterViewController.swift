//
//  RegisterViewController.swift
//  TestFinalProject
//
//  Created by Chandrakanth on 4/22/20.
//  Copyright © 2020 Pavan Rao. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class CellClass:UITableViewCell{
}

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    //Variable for the dropdown
    let transparentView = UIView()
    var dataSource=[String]()
    let tableView=UITableView()
    var selectedButton = UIButton()
    @IBOutlet weak var roleDropdown: UIButton!
    
    //Role value will get stored here
    var role:String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self as? UITableViewDelegate
        tableView.dataSource = self as? UITableViewDataSource
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = true
        
        setUpElements()
    }
    
    func setUpElements(){
        
        errorLabel.alpha = 0
        
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
        
    }
    
    func validateFields() -> String? {
        
        //Check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""    ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all the fields"
        }
        
        //Check if password is secure
        let cleanedPasword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPasword) == false {
            return "Please make sure your password is at least 8 characters, contains a special character and a number"
        }
        let cleanEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isValidEmail(cleanEmail) == false {
            return "Please enter the valid email id"
        }
        return nil
    }
    
    
    @IBAction func register(_ sender: Any) {
        
        //Validate the fields
        let error = validateFields()
        
        if error != nil {
            
            showError(error!)
        }else{
            
            //Create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            //Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                //Check for errors
                if err != nil {
                    
                    self.showError("Error creating user")
                }else{
                    
                    //Setting the firstname for the role
                    Utilities.firstName = self.firstNameTextField.text!
                    
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["uid": result!.user.uid, "firstname":firstName, "lastname":lastName, "role":self.role ]) { (error) in
                        
                        if error != nil{
                            self.showError("Error saving user data")
                        }
                    }
                }
            }
            
            //Transition to the home screen
            self.showError("\(self.role) created successfully!")
        }
    }
    
    func showError(_ message:String){
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome(){
        
        let homeViewController = storyboard?.instantiateViewController(identifier:
            Constants.Storyboard.homeViewController) as?
            HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
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
    
       
       @objc func removeTransparentView(){
           let frames=roleDropdown.frame
           UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
               self.transparentView.alpha=0
               self.tableView.frame=CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
           }, completion: nil)
       }
    
         
        
    @IBAction func roleDrpDownEvent(_ sender: Any) {
        
        let roleList=["Student","Admin"];
        
        dataSource=roleList
        selectedButton = roleDropdown
        addTransparentView(frames: roleDropdown.frame)
        
    }
    
}


extension RegisterViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.allowsSelection = true
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
        
        if title! == "Role" {
            role = dataSource[indexPath.row]
        }else{
            role = dataSource[indexPath.row]
        }
        
        selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
        removeTransparentView()
    }
}
