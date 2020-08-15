//
//  StudentJobDisplayViewController.swift
//  TestFinalProject
//
//  Created by Pavan Rao on 4/25/20.
//  Copyright © 2020 Pavan Rao. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class StudentJobDisplayViewController: UIViewController {

    let db = Firestore.firestore()
    
    @IBOutlet weak var jobIdText: UILabel!
    var jobIdField: String?
    
    @IBOutlet weak var positionText: UILabel!
    var positionField: String?
    
    @IBOutlet weak var linkText2: UITextView!
    var linkField: String?
    
    @IBOutlet weak var deadlineText: UILabel!
    var deadlineField: String?
    
    @IBOutlet weak var locationText: UILabel!
    var locationField: String?
    
    @IBOutlet weak var companyText: UILabel!
    var companyField: String?
    
    @IBOutlet weak var logo: UIImageView!
    var imageURL: String?
    
    //Variable for the dropdown
    let transparentView = UIView()
    var dataSource=[String]()
    let tableView=UITableView()
    var selectedButton = UIButton()
    var dropdownValue:String?
    
    @IBOutlet weak var statusText: UITextField!
    
    @IBOutlet weak var statusButton: UIButton!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            jobIdText.text = jobIdField
            positionText.text = positionField
            companyText.text = companyField
            locationText.text = locationField
            deadlineText.text = deadlineField
            linkText2.text = linkField
            linkText2.isEditable = false;
            linkText2.dataDetectorTypes = UIDataDetectorTypes.all;
        
            //For the dropdown
            tableView.delegate = self as? UITableViewDelegate
            tableView.dataSource = self as? UITableViewDataSource
            tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
            tableView.allowsSelection = true
            
            print("Begin of code")
            let url = URL(string: self.imageURL ?? "https://cdn.arstechnica.net/wp-content/uploads/2018/06/macOS-Mojave-Dynamic-Wallpaper-transition.jpg")!
            downloadImage(from: url)
            print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")

            
            // Do any additional setup after loading the view.
        }
        
        func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
            URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        }
        
        func downloadImage(from url: URL) {
            print("Download Started")
            getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")
                DispatchQueue.main.async() {
                    self.logo.image = UIImage(data: data)
                }
            }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "UpdateJobStatus" {
                if segue.destination is StudentJobListViewController {
                    db.collection("application").addDocument(data:["status":dropdownValue, "userRef": Utilities.emailId, "jobRef": jobIdField!])
                    Utilities.appliedJobs.append(companyField!)
                }
            }
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
               let frames=statusButton.frame
               UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                   self.transparentView.alpha=0
                   self.tableView.frame=CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
               }, completion: nil)
           }
    
          
        @IBAction func roleDrpDownEvent(_ sender: Any) {
            
            let statusList=["Applied","Rejected"];
            
            dataSource=statusList
            selectedButton = statusButton
            addTransparentView(frames: statusButton.frame)
            
        }
    }

extension StudentJobDisplayViewController : UITableViewDelegate, UITableViewDataSource {
    
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
        
        if title! == "Status" {
            dropdownValue = dataSource[indexPath.row]
        }else{
            dropdownValue = dataSource[indexPath.row]
        }
        
        selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
        removeTransparentView()
    }
}

