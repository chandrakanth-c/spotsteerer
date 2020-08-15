//
//  SignInViewController.swift
//  TestFinalProject
//
//  Created by Chandrakanth on 4/22/20.
//  Copyright © 2020 Pavan Rao. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var roleButton: UIButton!
    
    
    //Variable for the dropdown
    let transparentView = UIView()
    var dataSource=[String]()
    let tableView=UITableView()
    var selectedButton = UIButton()
    @IBOutlet weak var roleDropdown: UIButton!
    
    let db = Firestore.firestore()
    
    var role: String?
    
    //For the background image
    let backgroundImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self as? UITableViewDelegate
        tableView.dataSource = self as? UITableViewDataSource
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = true
        
        setUpElements()
        //setUpRole()
    }
    
    func setUpRole(){
        
        db.collection("users").whereField("firstname", isEqualTo: Utilities.firstName)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        self.role = "\(document.data()["role"] ?? "")"
                    }
                }
        }
        
    }
    
    func setUpBackground(){
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundImageView.image = UIImage(named: "Image")
    }
    
    func setUpElements(){
         
         errorLabel.alpha = 0
         
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
         
    }
    
    func validateFields() -> String? {
           
           //Check that all fields are filled in
           if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
               passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
               
               return "Please fill in all the fields"
           }
           
           //Check if password is secure
           let cleanedPasword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
           if Utilities.isPasswordValid(cleanedPasword) == false {
               return "Please make sure your password is at least 8 characters, contains a special character and a number"
           }
           return nil
    }
    
    @IBAction func login(_ sender: Any) {
        
        //Validate text fields
        let error = validateFields()
        
        if error != nil {
            
            showError(error!)
        }else{
            
            //Creating clean versions of email and password
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //Setting the value to email util variable for reusability
            Utilities.emailId = email
            
            //Signing in user
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                
                if error != nil {
                    
                    self.errorLabel.text = error?.localizedDescription
                    self.errorLabel.alpha = 1
                }else{
                    

                    if self.role == "Student" {
                        let studentHomeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.studentHomeViewController) as? StudentHomeController
                        self.view.window?.rootViewController = studentHomeViewController
                        self.view.window?.makeKeyAndVisible()
                    }
                    else {
                        let adminHomeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.adminHomeViewController) as? AdminHomeController
                        self.view.window?.rootViewController = adminHomeViewController
                        self.view.window?.makeKeyAndVisible()
                    }
                    
                }
            }
            
        }
    }
    
    func showError(_ message:String){
           
           errorLabel.text = message
           errorLabel.alpha = 1
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
              let frames=roleButton.frame
              UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                  self.transparentView.alpha=0
                  self.tableView.frame=CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
              }, completion: nil)
          }
    
    @IBAction func roleDrpDownEvent(_ sender: Any) {
        
        let roleList=["Student","Admin"];
        
        dataSource=roleList
        selectedButton = roleButton
        addTransparentView(frames: roleButton.frame)
        
    }
}

extension SignInViewController : UITableViewDelegate, UITableViewDataSource {
    
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
